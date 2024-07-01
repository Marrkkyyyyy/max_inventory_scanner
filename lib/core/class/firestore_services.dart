import 'dart:io';
import 'dart:typed_data';

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
        DocumentSnapshot existingPackage = existingPackages.docs.first;
        Map<String, dynamic> data =
            existingPackage.data() as Map<String, dynamic>;

        if (data['status'] == status) {
          return PackageResult.isDuplicate;
        }

        DocumentReference packageRef = existingPackage.reference;

        Map<String, dynamic> logs = data['logs'] as Map<String, dynamic>;
        String newLogKey = 'log${logs.length + 1}';
        logs[newLogKey] = {
          'timestamp': FieldValue.serverTimestamp(),
          'status': status,
        };

        WriteBatch batch = _firestore.batch();

        batch.update(packageRef, {
          'status': status,
          'logs': logs,
        });

        List<Map<String, dynamic>> containsPackages =
            List<Map<String, dynamic>>.from(data['containsPackages'] ?? []);

        if (containsPackages.isNotEmpty) {
          for (var packageInfo in containsPackages) {
            String containedTrackingNumber = packageInfo['trackingNumber'];
            QuerySnapshot containedPackageSnapshot = await _firestore
                .collection('Packages')
                .where('trackingNumber', isEqualTo: containedTrackingNumber)
                .limit(1)
                .get();

            if (containedPackageSnapshot.docs.isNotEmpty) {
              DocumentReference containedPackageRef =
                  containedPackageSnapshot.docs.first.reference;
              Map<String, dynamic> containedData =
                  containedPackageSnapshot.docs.first.data()
                      as Map<String, dynamic>;
              Map<String, dynamic> containedLogs =
                  containedData['logs'] as Map<String, dynamic>;
              String newContainedLogKey = 'log${containedLogs.length + 1}';

              batch.update(containedPackageRef, {
                'status': status,
                'logs.$newContainedLogKey': {
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': status,
                }
              });
            }
          }
        }

        await batch.commit();

        return PackageResult.success;
      } else {
        DocumentReference newPackageRef =
            await _firestore.collection('Packages').add({
          'rawTrackingNumber': rawTrackingNumber,
          'trackingNumber': trackingNumber,
          'carrier': carrier,
          'status': status,
          'consolidatedInto': null,
          'containsPackages': [],
          'photoUrl': null,
          'problemType': null,
          'logs': {
            'log1': {
              'timestamp': FieldValue.serverTimestamp(),
              'status': status,
            }
          }
        });

        String packageId = newPackageRef.id;
        await newPackageRef.update({'packageId': packageId});

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
      List<Map<String, String>> existingContainsPackages = [];
      bool isNewConsolidatedPackage = false;

      if (existingConsolidatedPackage.docs.isNotEmpty) {
        consolidatedPackageRef =
            existingConsolidatedPackage.docs.first.reference;
        Map<String, dynamic> data = existingConsolidatedPackage.docs.first
            .data() as Map<String, dynamic>;
        existingContainsPackages =
            List<Map<String, String>>.from(data['containsPackages'] ?? []);
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
          'containsPackages': [],
          'logs': {
            'log1': {
              'timestamp': FieldValue.serverTimestamp(),
              'status': 'consolidated',
            }
          }
        });

        String consolidatedPackageId = consolidatedPackageRef.id;
        await consolidatedPackageRef
            .update({'packageId': consolidatedPackageId});
      }

      List<Map<String, String>> newPackagesToAdd = [];
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
        Map<String, dynamic> data = packageDoc.data() as Map<String, dynamic>;

        Map<String, String> packageInfo = {
          'rawTrackingNumber': data['rawTrackingNumber'],
          'trackingNumber': data['trackingNumber'],
        };

        if (!existingContainsPackages.contains(packageInfo)) {
          newPackagesToAdd.add(packageInfo);

          Map<String, dynamic> logs = data['logs'] as Map<String, dynamic>;
          String newLogKey = 'log${logs.length + 1}';

          batch.update(packageDoc.reference, {
            'consolidatedInto': consolidatedPackageRef.id,
            'status': 'consolidated',
            'logs.$newLogKey': {
              'timestamp': FieldValue.serverTimestamp(),
              'status': 'consolidated',
            }
          });
        }
      }

      if (newPackagesToAdd.isNotEmpty) {
        batch.update(consolidatedPackageRef, {
          'containsPackages': FieldValue.arrayUnion(newPackagesToAdd),
          'status': 'consolidated',
        });

        if (!isNewConsolidatedPackage) {
          DocumentSnapshot consolidatedDoc = await consolidatedPackageRef.get();
          Map<String, dynamic> consolidatedData =
              consolidatedDoc.data() as Map<String, dynamic>;
          Map<String, dynamic> consolidatedLogs =
              consolidatedData['logs'] as Map<String, dynamic>;
          String newConsolidatedLogKey = 'log${consolidatedLogs.length + 1}';

          batch.update(consolidatedPackageRef, {
            'logs.$newConsolidatedLogKey': {
              'timestamp': FieldValue.serverTimestamp(),
              'status': 'consolidated',
            }
          });
        }

        await batch.commit();
      }

      return PackageResult.success;
    } catch (e) {
      return PackageResult.failure;
    }
  }
}
