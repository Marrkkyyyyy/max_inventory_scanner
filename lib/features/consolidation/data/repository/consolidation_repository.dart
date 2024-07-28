import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/enums/status_result.dart';
import 'package:max_inventory_scanner/core/model/log_model.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_service.dart';
import 'package:max_inventory_scanner/core/utils/check_internet.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/consolidation_package_model.dart';

abstract class ConsolidationRepository {
  Future<StatusResult> consolidatePackages({
    required String newConsolidatedTrackingNumber,
    required List<String> trackingNumbersToConsolidate,
    required double height,
    required double weight,
    required double length,
  });

  Future<bool> isPackageExisting(String trackingNumber);
}

class ConsolidationRepositoryImpl implements ConsolidationRepository {
  final FirebaseFirestore _firestore;

  ConsolidationRepositoryImpl(this._firestore);

  @override
  Future<bool> isPackageExisting(String trackingNumber) async {
    try {
      QuerySnapshot packageSnapshot = await _firestore
          .collection('Package')
          .where(Filter.or(
            Filter('rawTrackingNumber', isEqualTo: trackingNumber),
            Filter('trackingNumber', isEqualTo: trackingNumber),
          ))
          .where('status', whereIn: ['Receiving', 'Consolidated'])
          .limit(1)
          .get();
      return packageSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<StatusResult> consolidatePackages({
    required String newConsolidatedTrackingNumber,
    required List<String> trackingNumbersToConsolidate,
    required double height,
    required double weight,
    required double length,
  }) async {
    if (!await InternetChecker.checkInternet()) {
      return StatusResult.noInternet;
    }

    try {
      WriteBatch batch = _firestore.batch();

      PackageModel consolidatedPackage = await _findOrCreateConsolidatedPackage(
        newConsolidatedTrackingNumber,
        height,
        weight,
        length,
        batch,
      );

      _createLogEntry(batch, consolidatedPackage.packageID!, 'Consolidated');

      for (String trackingNumber in trackingNumbersToConsolidate) {
        if (trackingNumber == newConsolidatedTrackingNumber) continue;

        StatusResult result = await _processPackage(
          trackingNumber,
          consolidatedPackage.packageID!,
          batch,
        );

        if (result != StatusResult.success) return result;
      }

      await batch.commit();
      return StatusResult.success;
    } catch (e) {
      return StatusResult.failure;
    }
  }

  Future<PackageModel> _findOrCreateConsolidatedPackage(
    String trackingNumber,
    double height,
    double weight,
    double length,
    WriteBatch batch,
  ) async {
    QuerySnapshot existingPackage = await _firestore
        .collection('Package')
        .where(Filter.or(
          Filter('trackingNumber', isEqualTo: trackingNumber),
          Filter('rawTrackingNumber', isEqualTo: trackingNumber),
        ))
        .limit(1)
        .get();

    if (existingPackage.docs.isNotEmpty) {
      PackageModel package = PackageModel.fromJson(
        existingPackage.docs.first.data() as Map<String, dynamic>,
      );
      return _updateExistingPackage(package, height, weight, length, batch);
    } else {
      return _createNewPackage(trackingNumber, height, weight, length, batch);
    }
  }

  PackageModel _updateExistingPackage(
    PackageModel package,
    double height,
    double weight,
    double length,
    WriteBatch batch,
  ) {
    PackageModel updatedPackage = package.copyWith(
      status: 'Consolidated',
      consolidatedInto: 'self',
      height: height,
      weight: weight,
      length: length,
    );
    batch.update(_firestore.collection('Package').doc(package.packageID),
        updatedPackage.toJson());
    return updatedPackage;
  }

  PackageModel _createNewPackage(
    String trackingNumber,
    double height,
    double weight,
    double length,
    WriteBatch batch,
  ) {
    String? carrier = TrackingNumberService.identifyCourier(trackingNumber);
    String packageId = _firestore.collection('Package').doc().id;
    PackageModel newPackage = PackageModel(
      packageID: packageId,
      rawTrackingNumber: trackingNumber,
      trackingNumber: trackingNumber,
      carrier: carrier,
      status: 'Consolidated',
      consolidatedInto: 'self',
      height: height,
      weight: weight,
      length: length,
    );
    batch.set(
        _firestore.collection('Package').doc(packageId), newPackage.toJson());
    return newPackage;
  }

  void _createLogEntry(WriteBatch batch, String packageId, String status) {
    LogModel log = LogModel(
      logID: _firestore.collection('Log').doc().id,
      packageID: packageId,
      userID: '20',
      status: status,
      timestamp: FieldValue.serverTimestamp(),
    );
    batch.set(_firestore.collection('Log').doc(log.logID), log.toJson());
  }

  Future<StatusResult> _processPackage(
    String trackingNumber,
    String consolidatedPackageId,
    WriteBatch batch,
  ) async {
    QuerySnapshot packageSnapshot = await _firestore
        .collection('Package')
        .where(Filter.or(
          Filter('rawTrackingNumber', isEqualTo: trackingNumber),
          Filter('trackingNumber', isEqualTo: trackingNumber),
        ))
        .limit(1)
        .get();

    if (packageSnapshot.docs.isEmpty) return StatusResult.notFound;

    PackageModel package = PackageModel.fromJson(
      packageSnapshot.docs.first.data() as Map<String, dynamic>,
    );

    PackageModel updatedPackage = package.copyWith(
      status: 'Consolidated',
      consolidatedInto: consolidatedPackageId,
    );
    batch.update(packageSnapshot.docs.first.reference, updatedPackage.toJson());

    _createLogEntry(batch, package.packageID!, 'Consolidated');

    return StatusResult.success;
  }
}
