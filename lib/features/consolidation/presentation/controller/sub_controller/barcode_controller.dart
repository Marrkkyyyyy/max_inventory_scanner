// file: lib/features/consolidation/presentation/controller/barcode_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/package_photo_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/barcode_detected_bottom_sheet.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/repository/package_photo_repository.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/model/package_photo_info_model.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/controller/bottom_sheet_controller.dart';

class BarcodeController extends GetxController {
  // Dependencies
  final ConsolidationProcessController parentController;
  final PackagePhotoRepository _packagePhotoRepository;
  final PackagePhotoController packagePhotoController;

  // Observables
  final RxList<PackageInfo> detectedPackages = <PackageInfo>[].obs;
  final RxString barcodeResult = ''.obs;

  BarcodeController(this.parentController, this._packagePhotoRepository,
      this.packagePhotoController);

  // Public methods
  bool checkBarcodeExists(String barcode) {
    if (barcode == barcodeResult.value) {
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
    if (checkBarcodeExists(packageInfo.trackingNumber)) return false;
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

  void showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomScanner(
        onBarcodeDetected: (barcode) =>
            _handleBarcodeDetection(context, barcode),
      ),
    );
  }

  Future<List<PackagePhotoInfo>> fetchPhotoInfoForPackage(
      String trackingNumber) async {
    try {
      final package = await _packagePhotoRepository
          .getPackageByTrackingNumber(trackingNumber);
      if (package == null) return [];
      return await _packagePhotoRepository
          .getPhotoInfoForPackage(package.packageID!);
    } catch (e) {
      return [];
    }
  }

  void showBarcodeDetectedBottomSheet(
      BuildContext context, PackageInfo packageInfo, int? index,
      [bool exists = true,bool shouldCheckExistence = true]) {
    _resetPackagePhotoControllerState(packageInfo);
    _showBottomSheet(context, packageInfo, index, exists,shouldCheckExistence
    
     );
  }

  // Private methods
  void _handleBarcodeDetection(BuildContext context, String barcode) {
    Navigator.of(context).pop();
    if (!checkBarcodeExists(barcode)) {
      showBarcodeDetectedBottomSheet(
          context, PackageInfo(trackingNumber: barcode), null, false);
    }
  }

  void _resetPackagePhotoControllerState(PackageInfo packageInfo) {
    packagePhotoController.clearPhoto();
    if (packageInfo.image != null) {
      packagePhotoController.capturedImage.value = packageInfo.image;
      packagePhotoController.isImageCaptured.value = true;
    }
    packagePhotoController.selectedProblemType.value = packageInfo.problemType;
    packagePhotoController.showOtherProblemField.value =
        packageInfo.problemType == 'Other';
    packagePhotoController.otherProblemController.text =
        packageInfo.otherProblem ?? '';
  }

  void _showBottomSheet(
      BuildContext context, PackageInfo packageInfo, int? index, bool exists,
       bool shouldCheckExistence) {
    final String controllerTag =
        'barcode_bottom_sheet_${packageInfo.trackingNumber}';
    Get.put(
      BarcodeDetectedBottomSheetController(
        photoInfoFetcher: fetchPhotoInfoForPackage,
        trackingNumber: packageInfo.trackingNumber,
        packageExists: exists,
        shouldCheckExistence: shouldCheckExistence
      ),
      tag: controllerTag,
      permanent: false,
    );

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) =>
          _buildBottomSheetContent(context, packageInfo, index, controllerTag),
    ).then((_) {
      if (index == null) packagePhotoController.clearPhoto();
    });
  }

  Widget _buildBottomSheetContent(BuildContext context, PackageInfo packageInfo,
      int? index, String controllerTag) {
    return BarcodeDetectedBottomSheet(
      controllerTag: controllerTag,
      onCancel: () => Navigator.of(context).pop(),
      packageInfo: packageInfo,
      isEditing: index != null,
      onSaveAndExit: () => _handleSaveAndExit(context, packageInfo),
      onSaveAndNext: () => _handleSaveAndNext(context, packageInfo),
      onUpdate: index != null
          ? () => _handleUpdate(context, packageInfo, index)
          : null,
      onRemove: index != null ? () => _handleRemove(context, index) : null,
      onReScan: () => _handleReScan(context),
      onTogglePhoto: (value) => _handleTogglePhoto(value, packageInfo.image),
      onTakePhoto: () => packagePhotoController.takePhoto(),
      onViewPhoto: () => _handleViewPhoto(context),
      onProblemTypeChanged: _handleProblemTypeChanged,
      onOtherProblemChanged: (value) =>
          packagePhotoController.otherProblemController.text = value,
      packagePhotoController: packagePhotoController,
    );
  }

  void _handleSaveAndExit(BuildContext context, PackageInfo packageInfo) {
    _updatePackageInfo(packageInfo);
    addDetectedPackage(packageInfo);
    Navigator.pop(context);
  }

  void _handleSaveAndNext(BuildContext context, PackageInfo packageInfo) {
    _updatePackageInfo(packageInfo);
    addDetectedPackage(packageInfo);
    Navigator.pop(context);
    showScannerDialog(context);
  }

  void _handleUpdate(BuildContext context, PackageInfo packageInfo, int index) {
    _updatePackageInfo(packageInfo);
    updateDetectedPackage(index, packageInfo);
    Navigator.pop(context);
  }

  void _handleRemove(BuildContext context, int index) {
    removeDetectedPackage(index);
    Navigator.pop(context);
  }

  void _handleReScan(BuildContext context) {
    Navigator.pop(context);
    showScannerDialog(context);
  }

  void _handleTogglePhoto(bool? value, File? originalImage) {
    packagePhotoController.isImageCaptured.value = value ?? false;
    if (!packagePhotoController.isImageCaptured.value) {
      packagePhotoController.clearPhoto();
    } else if (originalImage != null) {
      packagePhotoController.capturedImage.value = originalImage;
    }
  }

  void _handleViewPhoto(BuildContext context) {
    parentController.showImageViewDialog(
      context,
      packagePhotoController.capturedImage.value!,
      packagePhotoController.takePhoto,
    );
  }

  void _handleProblemTypeChanged(String? value) {
    packagePhotoController.selectedProblemType.value = value;
    packagePhotoController.showOtherProblemField.value = value == 'Other';
    if (value != 'Other') {
      packagePhotoController.otherProblemController.clear();
    }
  }

  void _updatePackageInfo(PackageInfo packageInfo) {
    packageInfo.image = packagePhotoController.isImageCaptured.value
        ? packagePhotoController.capturedImage.value
        : null;
    packageInfo.problemType = packagePhotoController.selectedProblemType.value;
    packageInfo.otherProblem =
        packagePhotoController.selectedProblemType.value == 'Other'
            ? packagePhotoController.otherProblemController.text
            : null;
  }

  void _showInvalidTrackingNumberError() {
    _showError(
      'Invalid Tracking Number',
      'The scanned tracking number is the same as the consolidation tracking number.',
    );
  }

  void _showDuplicateTrackingNumberError() {
    _showError(
      'Duplicate Tracking Number',
      'This tracking number has already been added to the consolidation.',
    );
  }

  void _showError(String title, String message) {
    final currentFocus = FocusManager.instance.primaryFocus;
    SnackbarService.showCustomSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
    );
    currentFocus?.requestFocus();
  }
}
