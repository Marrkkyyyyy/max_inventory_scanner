import 'dart:async';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/image_service.dart';
import 'package:max_inventory_scanner/core/services/shared_preferences_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/core/widgets/manual_tracking_number.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/measurement_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/package_photo_controller.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/model/package_photo_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/repository/package_photo_repository.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/controller/bottom_sheet_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/image_view.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/barcode_detected_bottom_sheet.dart';

class ConsolidationProcessController extends GetxController {
  final SharedPreferencesService _myServices =
      Get.find<SharedPreferencesService>();
  final ConsolidationRepository _consolidationRepository;
  final PackagePhotoRepository _packagePhotoRepository;

  final TrackingNumberSearchService _trackingNumberSearchService;
  late final MeasurementController measurementController;
  late final PackagePhotoController packagePhotoController;

  final RxList<String> trackingSuggestions = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool packageExists = true.obs;

  Future<void> searchTrackingNumbers(String query) async {
    isLoading.value = true;
    List<String> results = await _trackingNumberSearchService
        .searchTrackingNumbers(query, location.value);
    trackingSuggestions.assignAll(results);
    isLoading.value = false;
  }

  final ImageService imageService;
  ConsolidationProcessController(this._consolidationRepository,
      this._trackingNumberSearchService, this._packagePhotoRepository)
      : imageService = ImageService();

  final RxString barcodeResult = ''.obs;
  final RxBool isNewBox = false.obs;
  final RxString location = ''.obs;

  // **********************************

  final Rx<File?> capturedImage = Rx<File?>(null);
  final RxBool isImageCaptured = false.obs;

  Future<void> takePhoto() async {
    final File? image = await imageService.takePhoto();
    if (image != null) {
      capturedImage.value = image;
      isImageCaptured.value = true;
      update();
    }
  }

  Widget buildPhotoButton(BuildContext context) {
    return Obx(() {
      if (!isNewBox.value && !packageExists.value) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton.icon(
              onPressed: isImageCaptured.value
                  ? () => _showImageViewDialog(
                      context, capturedImage.value!, takePhoto)
                  : takePhoto,
              icon: Icon(
                isImageCaptured.value ? Icons.photo : Icons.camera_alt,
                color: AppColor.white,
              ),
              label: Text(
                isImageCaptured.value ? "View Photo" : "Take a Photo",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor:
                      isImageCaptured.value ? AppColor.teal : AppColor.blue,
                  side: isImageCaptured.value
                      ? BorderSide(color: AppColor.teal)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))),
        );
      } else {
        return const SizedBox();
      }
    });
  }

// ********************************
  RxList<String> detectedBarcodes = <String>[].obs;
  final TextEditingController trackingNumberController =
      TextEditingController();

  RxList<PackageInfo> detectedPackages = <PackageInfo>[].obs;
  @override
  void onInit() {
    measurementController = Get.put(MeasurementController(this));
    packagePhotoController = Get.find<PackagePhotoController>();
    barcodeResult.value = Get.arguments['barcodeResult'];
    isNewBox.value = Get.arguments['isNewBox'];
    packageExists.value = Get.arguments['packageExists'];

    location.value = _myServices.getLocation() ?? '';
    super.onInit();
  }

  @override
  void onClose() {
    trackingNumberController.dispose();
    super.onClose();
  }

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
    await EasyLoading.show(status: 'Processing...');
    await Future.delayed(const Duration(seconds: 2));
    await EasyLoading.dismiss();
  }


  void showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          if (!checkBarcodeExists(barcode)) {
            showBarcodeDetectedBottomSheet(
                context, PackageInfo(trackingNumber: barcode), null, false);
          }
        },
      ),
    );
  }

  Future<List<PackagePhotoInfo>> fetchPhotoInfoForPackage(
      String trackingNumber) async {
    try {
      final package = await _packagePhotoRepository
          .getPackageByTrackingNumber(trackingNumber);

      if (package == null) {
        return [];
      }

      return await _packagePhotoRepository
          .getPhotoInfoForPackage(package.packageID!);
    } catch (e) {
      return [];
    }
  }

  void showBarcodeDetectedBottomSheet(
      BuildContext context, PackageInfo packageInfo, int? index, [bool exists = true]) {
    final File? originalImage = packageInfo.image;

    // Reset the PackagePhotoController state
    packagePhotoController.clearPhoto();
    if (originalImage != null) {
      packagePhotoController.capturedImage.value = originalImage;
      packagePhotoController.isImageCaptured.value = true;
    }
    packagePhotoController.selectedProblemType.value = packageInfo.problemType;
    packagePhotoController.showOtherProblemField.value =
        packageInfo.problemType == 'Other';
    packagePhotoController.otherProblemController.text =
        packageInfo.otherProblem ?? '';

    final String controllerTag =
        'barcode_bottom_sheet_${packageInfo.trackingNumber}';

    Get.put(
      BarcodeDetectedBottomSheetController(
        photoInfoFetcher: fetchPhotoInfoForPackage,
        trackingNumber: packageInfo.trackingNumber,
         packageExists: exists,
      ),
      tag: controllerTag,
      permanent: false,
    );

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BarcodeDetectedBottomSheet(
          controllerTag: controllerTag,
          onCancel: () async {
            Navigator.of(context).pop();
          },
          packageInfo: packageInfo,
          isEditing: index != null,
          onSaveAndExit: () {
            _updatePackageInfo(packageInfo);
            addDetectedPackage(packageInfo);
            Navigator.pop(context);
          },
          onSaveAndNext: () {
            _updatePackageInfo(packageInfo);
            addDetectedPackage(packageInfo);
            Navigator.pop(context);
            showScannerDialog(context);
          },
          onUpdate: index != null
              ? () {
                  _updatePackageInfo(packageInfo);
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
            packagePhotoController.isImageCaptured.value = value ?? false;
            if (!packagePhotoController.isImageCaptured.value) {
              packagePhotoController.clearPhoto();
            } else if (originalImage != null) {
              packagePhotoController.capturedImage.value = originalImage;
            }
          },
          onTakePhoto: () => packagePhotoController.takePhoto(),
          onViewPhoto: () => _showImageViewDialog(
            context,
            packagePhotoController.capturedImage.value!,
            packagePhotoController.takePhoto,
          ),
          onProblemTypeChanged: (String? value) {
            packagePhotoController.selectedProblemType.value = value;
            packagePhotoController.showOtherProblemField.value =
                value == 'Other';
            if (value != 'Other') {
              packagePhotoController.otherProblemController.clear();
            }
          },
          onOtherProblemChanged: (String value) {
            packagePhotoController.otherProblemController.text = value;
          },
          packagePhotoController: packagePhotoController,
        );
      },
    ).then((_) {
      if (index == null) {
        packagePhotoController.clearPhoto();
      }
    });
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

  void _showImageViewDialog(
      BuildContext context, File imageFile, VoidCallback onRetake) {
    Get.dialog(
      ImageViewDialog(
        imageFile: imageFile,
        onRetake: () {
          Get.back();
          takePhoto();
        },
      ),
      barrierDismissible: false,
    );
  }

 void showTrackingNumberEntry(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (val, {bool? isSuggestionSelected}) {
          Navigator.of(context).pop();
          if (!checkBarcodeExists(val)) {
            trackingNumberController.clear();
            bool exists = isSuggestionSelected ?? false;
            showBarcodeDetectedBottomSheet(
                context, PackageInfo(trackingNumber: val), null, exists);
          }
        },
        textEditingController: trackingNumberController,
        trackingSuggestions: trackingSuggestions,
        isLoading: isLoading,
        onSearch: searchTrackingNumbers,
      ),
    );
  }

  void _showInvalidTrackingNumberError() {
    final currentFocus = FocusManager.instance.primaryFocus;

    SnackbarService.showCustomSnackbar(
      title: 'Invalid Tracking Number',
      message:
          'The scanned tracking number is the same as the consolidation tracking number.',
      backgroundColor: Colors.red,
    );
    currentFocus?.requestFocus();
  }

  void _showDuplicateTrackingNumberError() {
    final currentFocus = FocusManager.instance.primaryFocus;
    SnackbarService.showCustomSnackbar(
      title: 'Duplicate Tracking Number',
      message:
          'This tracking number has already been added to the consolidation.',
      backgroundColor: Colors.red,
    );
    currentFocus?.requestFocus();
  }
}
