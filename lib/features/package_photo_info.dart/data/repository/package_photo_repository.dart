import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/model/log_model.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/consolidation_package_model.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/model/package_photo_info_model.dart';

abstract class PackagePhotoRepository {
  Future<PackageModel?> getPackageByTrackingNumber(String trackingNumber);
  Future<List<PackagePhotoInfo>> getPhotoInfoForPackage(String packageID);
}

class PackagePhotoRepositoryImpl implements PackagePhotoRepository {
  final FirebaseFirestore _firestore;

  PackagePhotoRepositoryImpl(this._firestore);

  @override
  Future<PackageModel?> getPackageByTrackingNumber(
      String trackingNumber) async {
    try {
      QuerySnapshot packageSnapshot = await _firestore
          .collection('Package')
          .where(Filter.or(
            Filter('trackingNumber', isEqualTo: trackingNumber),
            Filter('rawTrackingNumber', isEqualTo: trackingNumber),
          ))
          .limit(1)
          .get();

      if (packageSnapshot.docs.isNotEmpty) {
        return PackageModel.fromJson(
          packageSnapshot.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PackagePhotoInfo>> getPhotoInfoForPackage(
      String packageID) async {
    try {
      final logsSnapshot = await _firestore
          .collection('Log')
          .where('packageID', isEqualTo: packageID)
          .get();

      final logs = logsSnapshot.docs
          .map((doc) => LogModel.fromJson(doc.data()))
          .toList();

      final photoInfoList = <PackagePhotoInfo>[];

      for (final log in logs) {
        if (log.photoUrl != null && log.photoUrl!.isNotEmpty) {
          final problemSnapshot = await _firestore
              .collection('Problem')
              .where('packageID', isEqualTo: packageID)
              .get();

          String? problemType;
          if (problemSnapshot.docs.isNotEmpty) {
            problemType =
                problemSnapshot.docs.first.data()['problemType'] as String?;
          }

          photoInfoList.add(PackagePhotoInfo(
            status: log.status,
            photoUrl: log.photoUrl!,
            problemType: problemType,
          ));
        }
      }

      return photoInfoList;
    } catch (e) {
      return [];
    }
  }
}
