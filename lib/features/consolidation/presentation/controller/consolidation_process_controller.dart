import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:max_inventory_scanner/core/enums/status_result.dart';
import 'package:max_inventory_scanner/core/error/error_handler.dart';
import 'package:max_inventory_scanner/core/services/dialog_service.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';

class ConsolidationProcessController extends GetxController {
  final ConsolidationRepository _consolidationRepository;
  final DialogService dialogService;
  ConsolidationProcessController(this._consolidationRepository)
      : dialogService = DialogService();

  String? barcodeResult;
  RxList<String> detectedBarcodes = <String>[].obs;
  final TextEditingController trackingNumberController =
      TextEditingController();
  RxBool isConsolidating = false.obs;

  final TextEditingController lengthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  @override
  void onInit() {
    barcodeResult = Get.arguments['barcodeResult'];
    super.onInit();
  }

  @override
  void onClose() {
    trackingNumberController.dispose();
    lengthController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  void removeDetectedBarcode(int index) {
    detectedBarcodes.removeAt(index);
  }

  bool addDetectedBarcode(String barcode) {
    if (barcode == barcodeResult) {
      _showInvalidTrackingNumberError();
      return false;
    }
    if (detectedBarcodes.contains(barcode)) {
      _showDuplicateTrackingNumberError();
      return false;
    }
    detectedBarcodes.add(barcode);
    return true;
  }

  Future<void> consolidatePackages() async {
    if (isConsolidating.value) return;
    if (!_validateMeasurements()) return;

    bool? shouldProceed = await dialogService
        .showConsolidationConfirmationDialog(detectedBarcodes.isEmpty);
    if (shouldProceed != true) return;

    isConsolidating.value = true;
    EasyLoading.show(status: 'Consolidating packages...');

    try {
      StatusResult result = await _consolidationRepository.consolidatePackages(
        newConsolidatedTrackingNumber: barcodeResult!,
        trackingNumbersToConsolidate:
            detectedBarcodes.isEmpty ? [barcodeResult!] : detectedBarcodes,
        length: double.parse(lengthController.text),
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
      );
      ErrorHandler.handleConsolidationError(result);
    } finally {
      isConsolidating.value = false;
    }
  }

  bool _validateMeasurements() {
    if (_areMeasurementsEmpty()) {
      _showMissingMeasurementsError();
      return false;
    }
    if (!_areMeasurementsValid()) {
      _showInvalidMeasurementsError();
      return false;
    }
    return true;
  }

  bool _areMeasurementsEmpty() =>
      lengthController.text.isEmpty ||
      weightController.text.isEmpty ||
      heightController.text.isEmpty;

  bool _areMeasurementsValid() {
    try {
      double.parse(lengthController.text);
      double.parse(weightController.text);
      double.parse(heightController.text);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showInvalidTrackingNumberError() {
    SnackbarService.showCustomSnackbar(
      title: 'Invalid Tracking Number',
      message:
          'The scanned tracking number is the same as the consolidation tracking number.',
      backgroundColor: Colors.red,
    );
  }

  void _showDuplicateTrackingNumberError() {
    SnackbarService.showCustomSnackbar(
      title: 'Duplicate Tracking Number',
      message:
          'This tracking number has already been added to the consolidation.',
      backgroundColor: Colors.red,
    );
  }

  void _showMissingMeasurementsError() {
    SnackbarService.showCustomSnackbar(
      title: 'Missing Measurements',
      message:
          'Please enter length, weight, and height for the consolidated package.',
      backgroundColor: Colors.red,
    );
  }

  void _showInvalidMeasurementsError() {
    SnackbarService.showCustomSnackbar(
      title: 'Invalid Measurements',
      message: 'Please enter valid numbers for length, weight, and height.',
      backgroundColor: Colors.red,
    );
  }
}
