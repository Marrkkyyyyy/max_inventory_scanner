// file: lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'service_result.dart';
import '../functions/check_internet.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PackageResult> savePackage({
    required String rawTrackingNumber,
    required String trackingNumber,
    required String carrier,
  }) async {
    if (!await InternetChecker.checkInternet()) {
      return PackageResult.noInternet;
    }

    try {
      QuerySnapshot existingPackages = await _firestore
          .collection('Packages')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .where('status', isEqualTo: 'received')
          .get();

      if (existingPackages.docs.isNotEmpty) {
        return PackageResult.isDuplicate;
      }

      DocumentReference newPackageRef =
          await _firestore.collection('Packages').add({
        'rawTrackingNumber': rawTrackingNumber,
        'trackingNumber': trackingNumber,
        'carrier': carrier,
        'status': 'received',
        'currentLocation': 'receiving',
        'consolidatedInto': null,
        'containsPackages': [],
        'problemType': null,
        'photoUrl': null,
        'scans': {
          'scan1': {
            'timestamp': FieldValue.serverTimestamp(),
            'location': 'receiving',
          }
        }
      });

      String packageId = newPackageRef.id;

      await newPackageRef.update({'packageId': packageId});

      return PackageResult.success;
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
      // First, check if all packages exist and get their references
      QuerySnapshot packagesSnapshot = await _firestore
          .collection('Packages')
          .where('trackingNumber', whereIn: trackingNumbersToConsolidate)
          .where('status', isEqualTo: 'received')
          .get();

      if (packagesSnapshot.docs.length != trackingNumbersToConsolidate.length) {
        print('Some packages were not found or are not in received status');

      }

      // Create the new consolidated package
      DocumentReference newConsolidatedPackageRef =
          await _firestore.collection('Packages').add({
        'trackingNumber': newConsolidatedTrackingNumber,
        'status': 'consolidated',
        'currentLocation': 'sorting',
        'containsPackages': trackingNumbersToConsolidate,
        'scans': {
          'scan1': {
            'timestamp': FieldValue.serverTimestamp(),
            'location': 'sorting',
          }
        }
      });

      String newConsolidatedPackageId = newConsolidatedPackageRef.id;

      // Update the new consolidated package with its ID
      await newConsolidatedPackageRef
          .update({'packageId': newConsolidatedPackageId});

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update each package being consolidated
      for (DocumentSnapshot packageDoc in packagesSnapshot.docs) {
        batch.update(packageDoc.reference, {
          'consolidatedInto': newConsolidatedPackageId,
          'status': 'consolidated',
        });
      }

      // Commit the batch
      await batch.commit();

      return PackageResult.success;
    } catch (e) {
      print('Error during consolidation: $e');
      return PackageResult.failure;
    }
  }
}
