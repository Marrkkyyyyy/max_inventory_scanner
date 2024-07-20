import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/dialog_service.dart';
import 'package:max_inventory_scanner/core/services/image_service.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/image_view.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/tracking_number_entry_modal.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/barcode_detected_bottom_sheet.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/package_measurement.dart';

class ConsolidationProcessController extends GetxController {
  final ConsolidationRepository _consolidationRepository;
  final ImageService imageService;
  final DialogService dialogService;

  ConsolidationProcessController(this._consolidationRepository)
      : dialogService = DialogService(),
        imageService = ImageService();

  String? barcodeResult;
  RxList<String> detectedBarcodes = <String>[].obs;
  final TextEditingController trackingNumberController =
      TextEditingController();
  RxBool isConsolidating = false.obs;

  final TextEditingController lengthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  RxList<PackageInfo> detectedPackages = <PackageInfo>[].obs;
  final RxBool isImageCaptured = false.obs;
  final Rx<File?> capturedImage = Rx<File?>(null);
  final RxBool hasProblem = false.obs;
  final Rx<String?> selectedProblemType = Rx<String?>(null);
  final RxBool showOtherProblemField = false.obs;
  final TextEditingController otherProblemController = TextEditingController();

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
    otherProblemController.dispose();
    super.onClose();
  }

  void clearPhoto() {
    capturedImage.value = null;
    isImageCaptured.value = false;
    selectedProblemType.value = null;
    showOtherProblemField.value = false;
    otherProblemController.clear();
    update();
  }

  Future<void> takePhoto() async {
    File? image = await imageService.takePhoto();
    if (image != null) {
      capturedImage.value = image;
      isImageCaptured.value = true;
    } else {
      isImageCaptured.value = false;
    }
    update();
  }

  bool checkBarcodeExists(String barcode) {
    if (barcode == barcodeResult) {
      _showInvalidTrackingNumberError();
      return true;
    }
    if (detectedPackages.any((package) => package.trackingNumber == barcode)) {
      _showDuplicateTrackingNumberError();
      return true;
    }
    return false;
  }

  bool addDetectedPackage(PackageInfo packageInfo) {
    if (checkBarcodeExists(packageInfo.trackingNumber)) {
      return false;
    }
    detectedPackages.add(packageInfo);
    return true;
  }

  void updateDetectedPackage(int index, PackageInfo updatedPackage) {
    detectedPackages[index] = updatedPackage;
    update();
  }

  void removeDetectedPackage(int index) {
    detectedPackages.removeAt(index);
    update();
  }

  bool addDetectedBarcode(String barcode) {
    if (checkBarcodeExists(barcode)) {
      return false;
    }
    detectedBarcodes.add(barcode);
    return true;
  }

  Future<void> completeMeasurement() async {
    // Implement the logic for completing the measurement
  }

  void showMeasurementBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MeasurementBottomSheet(
          controller: this,
          onSaveAndNext: () {
            completeMeasurement();
            Navigator.of(context).pop();
            // Logic to start next consolidation
          },
          onSaveAndExit: () {
            completeMeasurement();
            Navigator.of(context).pop();
            Get.back(); // Exit the consolidation process
          },
        );
      },
    );
  }

  void showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          if (!checkBarcodeExists(barcode)) {
            showBarcodeDetectedBottomSheet(
                context, PackageInfo(trackingNumber: barcode), null);
          }
        },
      ),
    );
  }

  void showBarcodeDetectedBottomSheet(
      BuildContext context, PackageInfo packageInfo, int? index) {
    // Create local Rx variables to manage state within the bottom sheet
    final RxBool localIsImageCaptured = (packageInfo.image != null).obs;
    final Rx<File?> localCapturedImage = Rx<File?>(packageInfo.image);
    final Rx<String?> localSelectedProblemType =
        Rx<String?>(packageInfo.problemType);
    final RxBool localShowOtherProblemField =
        (packageInfo.problemType == 'Other').obs;
    final TextEditingController localOtherProblemController =
        TextEditingController(text: packageInfo.otherProblem);
    final File? originalImage = packageInfo.image;

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => BarcodeDetectedBottomSheet(
        packageInfo: packageInfo,
        isEditing: index != null,
        onSaveAndExit: () {
          _updatePackageInfo(
            packageInfo,
            localIsImageCaptured.value,
            localCapturedImage.value,
            localSelectedProblemType.value,
            localOtherProblemController.text,
          );
          addDetectedPackage(packageInfo);
          Navigator.pop(context);
        },
        onSaveAndNext: () {
          _updatePackageInfo(
            packageInfo,
            localIsImageCaptured.value,
            localCapturedImage.value,
            localSelectedProblemType.value,
            localOtherProblemController.text,
          );
          addDetectedPackage(packageInfo);
          Navigator.pop(context);
          showScannerDialog(context);
        },
        onUpdate: index != null
            ? () {
                _updatePackageInfo(
                  packageInfo,
                  localIsImageCaptured.value,
                  localCapturedImage.value,
                  localSelectedProblemType.value,
                  localOtherProblemController.text,
                );
                updateDetectedPackage(index, packageInfo);
                Navigator.pop(context);
              }
            : null,
        onRemove: index != null
            ? () {
                removeDetectedPackage(index);
                Navigator.pop(context);
              }
            : null,
        onReScan: () {
          Navigator.pop(context);
          showScannerDialog(context);
        },
        onTogglePhoto: (bool? value) {
          localIsImageCaptured.value = value ?? false;
          if (!localIsImageCaptured.value) {
            localCapturedImage.value = null;
            localSelectedProblemType.value = null;
            localShowOtherProblemField.value = false;
            localOtherProblemController.clear();
          } else if (originalImage != null) {
            localCapturedImage.value = originalImage;
          }
        },
        onTakePhoto: () async {
          await takePhoto();
          localCapturedImage.value = capturedImage.value;
          localIsImageCaptured.value = localCapturedImage.value != null;
        },
        onViewPhoto: () => _showImageViewDialog(
          context,
          localCapturedImage.value!,
          () async {
            Get.back();
            await takePhoto();
            localCapturedImage.value = capturedImage.value;
            localIsImageCaptured.value = localCapturedImage.value != null;
          },
        ),
        onProblemTypeChanged: (String? value) {
          localSelectedProblemType.value = value;
          localShowOtherProblemField.value = value == 'Other';
          if (value != 'Other') {
            localOtherProblemController.clear();
          }
        },
        onOtherProblemChanged: (String value) {
          localOtherProblemController.text = value;
        },
        isImageCaptured: localIsImageCaptured,
        capturedImage: localCapturedImage,
        selectedProblemType: localSelectedProblemType,
        showOtherProblemField: localShowOtherProblemField,
        otherProblemController: localOtherProblemController,
      ),
    ).then((_) {
      if (index == null) {
        clearPhoto();
      }
    });
  }

  void _updatePackageInfo(PackageInfo packageInfo, bool isImageCaptured,
      File? capturedImage, String? selectedProblemType, String otherProblem) {
    packageInfo.image = isImageCaptured ? capturedImage : null;
    packageInfo.problemType = selectedProblemType;
    packageInfo.otherProblem =
        selectedProblemType == 'Other' ? otherProblem : null;
  }

  void _showImageViewDialog(
      BuildContext context, File imageFile, VoidCallback onRetake) {
    Get.dialog(
      ImageViewDialog(
        imageFile: imageFile,
        onRetake: onRetake,
      ),
      barrierDismissible: false,
    );
  }

  void showTrackingNumberEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (val) {
          Navigator.of(context).pop();
          if (!checkBarcodeExists(val)) {
            showBarcodeDetectedBottomSheet(
                context, PackageInfo(trackingNumber: val), null);
          }
        },
        controller: trackingNumberController,
      ),
    );
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
}
