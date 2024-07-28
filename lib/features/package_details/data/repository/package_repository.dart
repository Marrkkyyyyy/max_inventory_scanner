import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/utils/check_internet.dart';
import 'package:max_inventory_scanner/features/package_details/data/model/package_check_result.dart';
import 'package:max_inventory_scanner/features/package_details/data/model/problem_model.dart';
import '../model/package_model.dart';
import '../../../../core/model/log_model.dart';
import '../../../../core/model/client_model.dart';
import '../../../../core/enums/status_result.dart';

abstract class PackageRepository {
  Future<StatusResult> savePackage(PackageModel package, String userID,
      {String? photoUrl, bool isDamaged, String? problemType});
  Future<StatusResult> savePackageRoatan(PackageModel package, String userID,
      {String? photoUrl, bool isDamaged, String? problemType});
  Future<PackageCheckResult> checkPackageExists(
      String trackingNumber, String location);
}

class PackageRepositoryImpl implements PackageRepository {
  final FirebaseFirestore _firestore;

  PackageRepositoryImpl(this._firestore);

  @override
  Future<StatusResult> savePackageRoatan(PackageModel package, String userID,
      {String? photoUrl, bool isDamaged = false, String? problemType}) async {
    try {
      if (!await InternetChecker.checkInternet()) {
        return StatusResult.noInternet;
      }

      QuerySnapshot existingPackages = await _firestore
          .collection('Package')
          .where(Filter.or(
            Filter('rawTrackingNumber', isEqualTo: package.rawTrackingNumber),
            Filter('trackingNumber', isEqualTo: package.trackingNumber),
          ))
          .get();

      if (existingPackages.docs.isEmpty) {
        return StatusResult.notFound;
      }

      String packageID = existingPackages.docs.first.id;
      await _firestore.collection('Package').doc(packageID).update({
        'status': 'Roatan',
      });

      String? problemID;
      if (isDamaged && problemType != null) {
        problemID = await _createProblemEntry(packageID, problemType, photoUrl);
      }

      await _createLogEntry(packageID, userID, 'Roatan', problemID, photoUrl);

      return StatusResult.success;
    } catch (e) {
      return StatusResult.failure;
    }
  }

  @override
  Future<StatusResult> savePackage(PackageModel package, String userID,
      {String? photoUrl, bool isDamaged = false, String? problemType}) async {
    try {
      if (!await InternetChecker.checkInternet()) {
        return StatusResult.noInternet;
      }

      String? clientID = await _getOrCreateClient(package.clientName);
      package.clientID = clientID;

      QuerySnapshot existingPackages = await _firestore
          .collection('Package')
          .where('trackingNumber', isEqualTo: package.trackingNumber)
          .get();

      late String packageID;
      if (existingPackages.docs.isEmpty) {
        DocumentReference newPackageRef =
            await _firestore.collection('Package').add(package.toJson()
              ..remove('clientName')
              ..remove('timestamp'));
        packageID = newPackageRef.id;
        await newPackageRef.update({'packageID': packageID});
      } else {
        packageID = existingPackages.docs.first.id;
        await _firestore.collection('Package').doc(packageID).update({
          'status': package.status,
          'note': package.note,
          'clientID': clientID,
        });
      }

      String? problemID;
      if (isDamaged && problemType != null) {
        problemID = await _createProblemEntry(packageID, problemType, photoUrl);
      }

      await _createLogEntry(
          packageID, userID, package.status!, problemID, photoUrl);

      return StatusResult.success;
    } catch (e) {
      return StatusResult.failure;
    }
  }

  Future<String?> _getOrCreateClient(String? clientName) async {
    if (clientName == null || clientName.isEmpty) {
      return null;
    }

    QuerySnapshot clientQuery = await _firestore
        .collection('Client')
        .where('name', isEqualTo: clientName)
        .limit(1)
        .get();

    if (clientQuery.docs.isNotEmpty) {
      return clientQuery.docs.first.id;
    } else {
      ClientModel newClient = ClientModel(
        name: clientName,
        accountID: '',
      );

      DocumentReference newClientRef =
          await _firestore.collection('Client').add(newClient.toJson());
      String clientID = newClientRef.id;
      await newClientRef.update({'clientID': clientID});

      return clientID;
    }
  }

  Future<void> _createLogEntry(String packageID, String userID, String status,
      String? problemID, String? photoUrl) async {
    LogModel logEntry = LogModel(
      packageID: packageID,
      userID: userID,
      problemID: problemID,
      photoUrl: photoUrl,
      status: status,
      timestamp: FieldValue.serverTimestamp(),
    );

    DocumentReference newLogRef =
        await _firestore.collection('Log').add(logEntry.toJson());
    String logID = newLogRef.id;
    await newLogRef.update({'logID': logID});
  }

  Future<String> _createProblemEntry(
      String packageID, String problemType, String? photoUrl) async {
    ProblemModel problemEntry = ProblemModel(
      packageID: packageID,
      problemType: problemType,
      timestamp: FieldValue.serverTimestamp(),
    );

    DocumentReference newProblemRef =
        await _firestore.collection('Problem').add(problemEntry.toJson());
    String problemID = newProblemRef.id;
    await newProblemRef.update({'problemID': problemID});

    return problemID;
  }

  @override
  Future<PackageCheckResult> checkPackageExists(
      String trackingNumber, String location) async {
    try {
      if (!await InternetChecker.checkInternet()) {
        return PackageCheckResult(StatusResult.noInternet);
      }

      QuerySnapshot result = await _firestore
          .collection('Package')
          .where(Filter.or(
            Filter('rawTrackingNumber', isEqualTo: trackingNumber),
            Filter('trackingNumber', isEqualTo: trackingNumber),
          ))
          .get();

      if (result.docs.isNotEmpty) {
        List<PackageModel> packages = result.docs
            .map((doc) =>
                PackageModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        List<PackageModel> sameStatusPackages = packages.where((package) {
          String packageStatus = package.status?.toLowerCase() ?? '';
          return packageStatus == location.toLowerCase();
        }).toList();

        if (sameStatusPackages.isNotEmpty) {
          PackageModel latestPackage = sameStatusPackages.reduce(
              (a, b) => a.timestamp!.compareTo(b.timestamp!) > 0 ? a : b);

          return PackageCheckResult(
            StatusResult.duplicateFound,
            note: latestPackage.note,
            status: latestPackage.status?.toLowerCase(),
          );
        } else {
          return PackageCheckResult(StatusResult.success);
        }
      } else {
        return PackageCheckResult(StatusResult.success);
      }
    } catch (e) {
      return PackageCheckResult(StatusResult.failure);
    }
  }
}
