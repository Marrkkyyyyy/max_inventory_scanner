// file: lib/features/consolidation/presentation/controller/measurement_controller.dart

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/dialog_service.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/client_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/package_measurement.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class MeasurementController extends GetxController {
  // Dependencies
  final ConsolidationProcessController consolidationProcessController;
  final DialogService dialogService;
  final ClientController _clientController;

  // Controllers
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  // Observables
  final RxString lengthError = ''.obs;
  final RxString weightError = ''.obs;
  final RxString heightError = ''.obs;

  MeasurementController(this.consolidationProcessController)
      : dialogService = DialogService(),
        _clientController = Get.find<ClientController>();

  @override
  void onClose() {
    lengthController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  void clearMeasurementErrors() {
    lengthError.value = '';
    weightError.value = '';
    heightError.value = '';
    update();
  }

  bool validateMeasurements() {
    bool isValid = true;
    isValid &= _validateField(lengthController, lengthError, 'Length');
    isValid &= _validateField(weightController, weightError, 'Weight');
    isValid &= _validateField(heightController, heightError, 'Height');
    update();
    return isValid;
  }

  bool _validateField(TextEditingController controller,
      RxString errorObservable, String fieldName) {
    if (controller.text.trim().isEmpty) {
      errorObservable.value = '$fieldName is required';
      return false;
    }
    errorObservable.value = '';
    return true;
  }

  Future<void> completeMeasurement() async {
    await EasyLoading.show(status: 'Processing...');
    await Future.delayed(const Duration(seconds: 2));
    await EasyLoading.dismiss();
  }

  Future<void> showMeasurementBottomSheet(BuildContext context) async {
    if (consolidationProcessController.isNewBox.value) {
      if (!_clientController.validateClientName()) {
        return;
      }
    } else if (!consolidationProcessController.isImageCaptured.value) {
      await _handlePhotoRequirement();
      if (!consolidationProcessController.isImageCaptured.value) return;
    }

    clearMeasurementErrors();
    _showBottomSheet(context);
  }

  Future<void> _handlePhotoRequirement() async {
    bool? shouldTakePhoto = await dialogService.showPhotoRequiredDialog(
        'Package not found. Please take a photo of the package label to proceed');
    if (shouldTakePhoto == null) return;
    if (shouldTakePhoto) {
      await consolidationProcessController.takePhoto();
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => MeasurementBottomSheet(
        onSaveAndExit: () => _handleSaveAndExit(context),
      ),
    ).then((_) => FocusManager.instance.primaryFocus!.unfocus());
  }

  Future<void> _handleSaveAndExit(BuildContext context) async {
    if (validateMeasurements()) {
      await completeMeasurement();
      Navigator.of(context).pop();
      Get.back();
    }
  }

  Future<void> saveAndNext(BuildContext context) async {
    if (validateMeasurements()) {
      await _processMeasurement();
      _navigateToNextScreen(context);
    }
  }

  Future<void> _processMeasurement() async {
    await EasyLoading.show(status: 'Processing...', dismissOnTap: false);
    await Future.delayed(const Duration(seconds: 2));
    await EasyLoading.dismiss();
  }

  void _navigateToNextScreen(BuildContext context) {
    Get.until((route) => Get.currentRoute == AppRoute.CONSOLIDATION);
    Future.delayed(const Duration(milliseconds: 100), () {
      final consolidationController = Get.find<ConsolidationController>();
      consolidationController.showConsolidationScanner(
        context,
        isNewBox: consolidationProcessController.isNewBox.value,
      );
    });
  }
}
