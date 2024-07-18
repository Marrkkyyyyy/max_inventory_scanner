import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/enums/status_result.dart';
import 'package:max_inventory_scanner/features/registration/data/model/user_check_result.dart';
import 'package:max_inventory_scanner/features/registration/data/repository/registration_repository.dart';
import '../../../../core/services/shared_preferences_service.dart';

class RegistrationController extends GetxController {
  final UserRepository _userRepository;
  RegistrationController(this._userRepository);
  final SharedPreferencesService _myServices =
      Get.find<SharedPreferencesService>();
  final RxString role = ''.obs;
  final RxString userName = ''.obs;
  final RxBool isNameValid = true.obs;
  final RxBool isRoleValid = true.obs;
  final TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.text = userName.value;
  }

  void setRole(String? value) {
    role.value = value ?? '';
    isRoleValid.value = role.value.isNotEmpty;
  }

  bool validateInputs() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
    isRoleValid.value = role.value.isNotEmpty;
    return isNameValid.value && isRoleValid.value;
  }

  Future<void> register() async {
    if (validateInputs()) {
      try {
        EasyLoading.show(status: 'Processing...');
        userName.value = nameController.text.trim();
        UserCheckResult result = await _userRepository.registerUser(
          name: userName.value,
          location: role.value,
        );

        if (result.result == StatusResult.success && result.userID != null) {
          await _myServices.registerUser(
              userName.value, role.value, result.userID!);
          Get.offAllNamed('/');
        } else {
          Get.snackbar('Error', 'Registration failed. Please try again.');
        }
      } catch (e) {
        Get.snackbar(
            'Error', 'An unexpected error occurred. Please try again.');
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
