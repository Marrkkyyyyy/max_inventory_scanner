import 'dart:async';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/client_service.dart';
import 'package:max_inventory_scanner/core/services/dialog_service.dart';
import 'package:max_inventory_scanner/core/services/image_service.dart';
import 'package:max_inventory_scanner/core/services/shared_preferences_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/core/widgets/manual_tracking_number.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/image_view.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/barcode_detected_bottom_sheet.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/package_measurement.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class ConsolidationProcessController extends GetxController {
  final SharedPreferencesService _myServices =
      Get.find<SharedPreferencesService>();
  final ClientService clientService;
  final ConsolidationRepository _consolidationRepository;

  final RxList<String> trackingSuggestions = <String>[].obs;
  final RxBool isLoading = false.obs;
  final TrackingNumberSearchService _trackingNumberSearchService;

  Future<void> searchTrackingNumbers(String query) async {
    isLoading.value = true;
    List<String> results =
        await _trackingNumberSearchService.searchTrackingNumbers(query);
    trackingSuggestions.assignAll(results);
    isLoading.value = false;
  }

  final ImageService imageService;
  final DialogService dialogService;
  ConsolidationProcessController(
    this._consolidationRepository,
    this._trackingNumberSearchService,
  )   : dialogService = DialogService(),
        clientService = ClientService(),
        imageService = ImageService();

  final TextEditingController clientNameController = TextEditingController();
  final RxBool isWarningVisible = false.obs;
  final RxBool isTextFieldFocused = false.obs;
  final RxBool showSuggestions = true.obs;
  final RxList<String> clientSuggestions = <String>[].obs;
  final RxBool isClientNameValid = true.obs;
  final RxString clientNameError = ''.obs;
  final RxBool isNameInClientList = true.obs;
  final RxString nameNotInListWarning = ''.obs;

  final RxString barcodeResult = ''.obs;
  final RxBool isNewBox = false.obs;
  final RxString location = ''.obs;

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
  final RxString lengthError = ''.obs;
  final RxString weightError = ''.obs;
  final RxString heightError = ''.obs;
  @override
  void onInit() {
    clientService.loadClients();
    barcodeResult.value = Get.arguments['barcodeResult'];
    isNewBox.value = Get.arguments['isNewBox'];
    location.value = _myServices.getLocation() ?? '';
    clientNameController.addListener(onClientNameChanged);
    super.onInit();
  }

  @override
  void onClose() {
    trackingNumberController.dispose();
    lengthController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherProblemController.dispose();
    clientNameController.removeListener(onClientNameChanged);
    clientNameController.dispose();
    clearMeasurementErrors();
    super.onClose();
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
            isNewBox: isNewBox.value);
      });
    }
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

  void onClientNameChanged() {
    final query = clientNameController.text.trim();
    clientSuggestions.value =
        query.isEmpty ? [] : clientService.getSuggestions(query);
    showSuggestions.value =
        isTextFieldFocused.value && clientSuggestions.isNotEmpty;

    isNameInClientList.value = clientService.isExactMatch(query);
    if (!isNameInClientList.value && query.isNotEmpty) {
      nameNotInListWarning.value =
          'Name not in client list. Verify or continue if it\'s a new client.';
      isWarningVisible.value = false;
    } else {
      nameNotInListWarning.value = '';
      isWarningVisible.value = false;
    }

    validateClientName();
  }

  bool validateClientName() {
    final name = clientNameController.text.trim();
    isClientNameValid.value = name.isNotEmpty;
    clientNameError.value =
        isClientNameValid.value ? '' : 'Client name is required';

    if (name.isNotEmpty && !clientService.isExactMatch(name)) {
      nameNotInListWarning.value =
          'Name not in client list. Verify or continue if it\'s a new client.';
      isWarningVisible.value = !isTextFieldFocused.value;
    } else {
      nameNotInListWarning.value = '';
      isWarningVisible.value = false;
    }

    update();
    return isClientNameValid.value;
  }

  void onClientNameFocusChanged(bool hasFocus) {
    isTextFieldFocused.value = hasFocus;
    if (!hasFocus) {
      validateClientName();
    }
    update();
  }

  void selectClientName(String name) {
    clientNameController.text = name;
    showSuggestions.value = false;
    isTextFieldFocused.value = false;
    validateClientName();
    update();
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

  void showMeasurementBottomSheet(BuildContext context) {
    if (isNewBox.value && !validateClientName()) {
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
          controller: this,
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
        onCancel: () {
          Navigator.of(context).pop();
        },
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
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (val) {
          Navigator.of(context).pop();
          if (!checkBarcodeExists(val)) {
            trackingNumberController.clear();
            showBarcodeDetectedBottomSheet(
                context, PackageInfo(trackingNumber: val), null);
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
