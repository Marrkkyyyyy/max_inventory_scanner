
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/enums/status_result.dart';
import 'package:max_inventory_scanner/core/utils/check_internet.dart';
import 'package:max_inventory_scanner/features/registration/data/model/user_check_result.dart';
import 'package:max_inventory_scanner/features/registration/data/model/user_model.dart';

abstract class UserRepository {
  Future<UserCheckResult> registerUser({
    required String name,
    required String location,
  });
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<UserCheckResult> registerUser({
    required String name,
    required String location,
  }) async {
    if (!await InternetChecker.checkInternet()) {
      return UserCheckResult(StatusResult.noInternet);
    }

    try {
      DocumentReference docRef = _firestore.collection('User').doc();
      String userID = docRef.id;

      UserModel newUser = UserModel(
        userID: userID,
        name: name,
        location: location,
      );

      await docRef.set(newUser.toJson());
      return UserCheckResult(StatusResult.success, userID: userID);
    } catch (e) {
      return UserCheckResult(StatusResult.failure);
    }
  }
}