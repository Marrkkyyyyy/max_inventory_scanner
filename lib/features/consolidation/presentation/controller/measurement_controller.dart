// file: lib/features/consolidation/presentation/controller/measurement_controller.dart

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/dialog_service.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/client_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/package_measurement.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class MeasurementController extends GetxController {
  final ConsolidationProcessController consolidationProcessController;
  final DialogService dialogService = DialogService();
  MeasurementController(this.consolidationProcessController);
  final ClientController _clientController = Get.find<ClientController>();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final RxString lengthError = ''.obs;
  final RxString weightError = ''.obs;
  final RxString heightError = ''.obs;

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

    if (lengthController.text.trim().isEmpty) {
      lengthError.value = 'Length is required';
      isValid = false;
    } else {
      lengthError.value = '';
    }

    if (weightController.text.trim().isEmpty) {
      weightError.value = 'Weight is required';
      isValid = false;
    } else {
      weightError.value = '';
    }

    if (heightController.text.trim().isEmpty) {
      heightError.value = 'Height is required';
      isValid = false;
    } else {
      heightError.value = '';
    }

    update();
    return isValid;
  }

  Future<void> completeMeasurement() async {
    await EasyLoading.show(status: 'Processing...');
    await Future.delayed(const Duration(seconds: 2));
    await EasyLoading.dismiss();
  }

  void showMeasurementBottomSheet(BuildContext context) async {
    if (consolidationProcessController.isNewBox.value &&
            !_clientController.validateClientName() ||
        !consolidationProcessController.isImageCaptured.value) {
      bool? shouldTakePhoto = await dialogService.showPhotoRequiredDialog();
      if (shouldTakePhoto == null) {
        return;
      }
      if (shouldTakePhoto) {
        await consolidationProcessController.takePhoto();
        if (!consolidationProcessController.isImageCaptured.value) {
          return;
        }
      } else {
        return;
      }
      return;
    }
    clearMeasurementErrors();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MeasurementBottomSheet(
          onSaveAndExit: () async {
            if (validateMeasurements()) {
              await completeMeasurement();
              Navigator.of(context).pop();
              Get.back();
            }
          },
        );
      },
    ).then((_) {
      FocusManager.instance.primaryFocus!.unfocus();
    });
  }

  Future<void> saveAndNext(BuildContext context) async {
    if (validateMeasurements()) {
      await EasyLoading.show(status: 'Processing...', dismissOnTap: false);
      await Future.delayed(const Duration(seconds: 2));
      await EasyLoading.dismiss();

      Get.until((route) => Get.currentRoute == AppRoute.CONSOLIDATION);

      Future.delayed(const Duration(milliseconds: 100), () {
        final consolidationController = Get.find<ConsolidationController>();
        consolidationController.showConsolidationScanner(context,
            isNewBox: consolidationProcessController.isNewBox.value);
      });
    }
  }
}
