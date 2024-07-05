import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/core/services/services.dart';
import 'package:max_inventory_scanner/utils/snackbar_service.dart';

class SettingsController extends GetxController {
  final MyServices _myServices = Get.find<MyServices>();
  final RxString role = ''.obs;
  final RxString userName = ''.obs;
  final RxBool isNameValid = true.obs;
  final RxBool isRoleValid = true.obs;

  final TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    userName.value = _myServices.getName() ?? '';
    role.value = _myServices.getLocation() ?? '';
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

  void saveSettings() {
    if (validateInputs()) {
      userName.value = nameController.text.trim();
      _myServices.saveSettings(userName.value, role.value);
      SnackbarService.showCustomSnackbar(
          title: 'Settings Saved',
          message: 'Your settings have been updated successfully',
          backgroundColor: Colors.teal.shade400);
      if (Get.isRegistered<HomePageController>()) {
        final homeController = Get.find<HomePageController>();
        homeController.resetTrackingNumberController();
      }
      Get.offAllNamed('/');
    }
  }

  final List<String> roles = [
    'Receiving',
    'Container',
    'Roatan',
    'Consolidation'
  ];

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
