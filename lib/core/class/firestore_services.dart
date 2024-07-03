import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../functions/carrier_and_tracking_number.dart';
import 'service_result.dart';
import '../functions/check_internet.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<PackageResult> reportIssue({
    required String trackingNumber,
    required String problemType,
    required File imageFile,
  }) async {
    if (!await InternetChecker.checkInternet()) {
      return PackageResult.noInternet;
    }

    try {
      String fileName =
          'issues/${DateTime.now().millisecondsSinceEpoch}_$trackingNumber.jpg';
      UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      QuerySnapshot existingPackages = await _firestore
          .collection('Packages')
          .where(Filter.or(
            Filter('rawTrackingNumber', isEqualTo: trackingNumber),
            Filter('trackingNumber', isEqualTo: trackingNumber),
          ))
          .limit(1)
          .get();

      if (existingPackages.docs.isNotEmpty) {
        DocumentReference packageRef = existingPackages.docs.first.reference;

        await packageRef.update({
          'photoUrl': downloadUrl,
          'problemType': problemType,
        });

        return PackageResult.success;
      } else {
        await _firestore.collection('DamagedPackages').add({
          'trackingNumber': trackingNumber,
          'problemType': problemType,
          'photoUrl': downloadUrl,
        });

        return PackageResult.success;
      }
    } catch (e) {
      return PackageResult.failure;
    }
  }

  Future<PackageResult> savePackage({
    required String rawTrackingNumber,
    required String trackingNumber,
    required String carrier,
    required String status,
  }) async {
    if (!await InternetChecker.checkInternet()) {
      return PackageResult.noInternet;
    }

    try {
      QuerySnapshot existingPackages = await _firestore
          .collection('Packages')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .get();

      if (existingPackages.docs.isNotEmpty) {
        return PackageResult.isDuplicate;
      } else {
        DocumentReference newPackageRef =
            await _firestore.collection('Packages').add({
          'rawTrackingNumber': rawTrackingNumber,
          'trackingNumber': trackingNumber,
          'carrier': carrier,
          'status': status,
          'consolidatedInto': null,
          'photoUrl': null,
          'problemType': null,
        });

        String packageId = newPackageRef.id;
        await newPackageRef.update({'packageId': packageId});

        // Add log entry
        await _firestore.collection('Logs').add({
          'timestamp': FieldValue.serverTimestamp(),
          'rawTrackingNumber': rawTrackingNumber,
          'trackingNumber': trackingNumber,
          'status': status,
        });

        return PackageResult.success;
      }
    } catch (e) {
      return PackageResult.failure;
    }
  }

  Future<PackageResult> consolidatePackages({
    required String newConsolidatedTrackingNumber,
    required List<String> trackingNumbersToConsolidate,
  }) async {
    if (!await InternetChecker.checkInternet()) {
      return PackageResult.noInternet;
    }

    try {
      QuerySnapshot existingConsolidatedPackage = await _firestore
          .collection('Packages')
          .where(Filter.or(
              Filter('trackingNumber',
                  isEqualTo: newConsolidatedTrackingNumber),
              Filter('rawTrackingNumber',
                  isEqualTo: newConsolidatedTrackingNumber)))
          .limit(1)
          .get();

      DocumentReference consolidatedPackageRef;
      bool isNewConsolidatedPackage = false;

      if (existingConsolidatedPackage.docs.isNotEmpty) {
        consolidatedPackageRef =
            existingConsolidatedPackage.docs.first.reference;
      } else {
        isNewConsolidatedPackage = true;
        String? consolidatedCourier =
            await identifyCourier(newConsolidatedTrackingNumber);

        consolidatedPackageRef = await _firestore.collection('Packages').add({
          'rawTrackingNumber': newConsolidatedTrackingNumber,
          'trackingNumber': newConsolidatedTrackingNumber,
          'carrier': consolidatedCourier ?? 'Unknown',
          'status': 'consolidated',
          'photoUrl': null,
          'problemType': null,
          'consolidatedInto': 'self',
        });

        String consolidatedPackageId = consolidatedPackageRef.id;
        await consolidatedPackageRef
            .update({'packageId': consolidatedPackageId});
      }

      WriteBatch batch = _firestore.batch();

      for (String trackingNumber in trackingNumbersToConsolidate) {
        QuerySnapshot packageSnapshot = await _firestore
            .collection('Packages')
            .where(Filter.or(
              Filter('rawTrackingNumber', isEqualTo: trackingNumber),
              Filter('trackingNumber', isEqualTo: trackingNumber),
            ))
            .limit(1)
            .get();

        if (packageSnapshot.docs.isEmpty) {
          return PackageResult.notFound;
        }

        DocumentSnapshot packageDoc = packageSnapshot.docs.first;
        batch.update(packageDoc.reference, {
          'consolidatedInto': consolidatedPackageRef.id,
        });

        // Add log entry
        await _firestore.collection('Logs').add({
          'timestamp': FieldValue.serverTimestamp(),
          'rawTrackingNumber': packageDoc['rawTrackingNumber'],
          'trackingNumber': packageDoc['trackingNumber'],
          'status': 'consolidated',
        });
      }

      await batch.commit();

      await _firestore.collection('Logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'rawTrackingNumber': newConsolidatedTrackingNumber,
        'trackingNumber': newConsolidatedTrackingNumber,
        'status': 'consolidated',
      });

      return PackageResult.success;
    } catch (e) {
      return PackageResult.failure;
    }
  }
}
