import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/enums/status_result.dart';
import 'package:max_inventory_scanner/core/services/client_service.dart';
import 'package:max_inventory_scanner/core/services/dialog_service.dart';
import 'package:max_inventory_scanner/core/services/image_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_service.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/features/package_details/data/model/package_check_result.dart';
import 'package:max_inventory_scanner/features/package_details/data/model/package_model.dart';
import 'package:max_inventory_scanner/features/package_details/data/repository/package_repository.dart';

class PackageDetailsController extends GetxController {
  final RxBool showDuplicateWarning = false.obs;
  final RxBool isTextFieldFocused = false.obs;
  final RxBool isProblemTypeValid = true.obs;
  final RxBool isOtherProblemValid = true.obs;
  final RxBool isPhotoRequired = false.obs;
  final RxBool hasProblem = false.obs;
  final Rx<String?> selectedProblemType = Rx<String?>(null);
  final RxBool showOtherProblemField = false.obs;
  final TextEditingController otherProblemController = TextEditingController();

  // List of problem types

  void toggleProblem(bool? value) {
    hasProblem.value = value ?? false;
    if (!hasProblem.value) {
      selectedProblemType.value = null;
      showOtherProblemField.value = false;
      otherProblemController.clear();
      isPhotoRequired.value = false;
    } else {
      isPhotoRequired.value = true;
    }
    validateClientName();
  }

  void selectProblemType(String? type) {
    selectedProblemType.value = type;
    showOtherProblemField.value = type == 'Other';
    if (type == 'No Name') {
      clientNameController.clear();
      isClientNameValid.value = true;
    }
    validateProblemFields();
  }

  void validateProblemFields() {
    isProblemTypeValid.value = selectedProblemType.value != null;
    isOtherProblemValid.value =
        !showOtherProblemField.value || otherProblemController.text.isNotEmpty;
    update();
  }

  void validateClientName() {
    if (hasProblem.value && selectedProblemType.value == 'No Name') {
      isClientNameValid.value = true;
      clientNameError.value = '';
    } else {
      isClientNameValid.value = clientNameController.text.trim().isNotEmpty;
      clientNameError.value =
          isClientNameValid.value ? '' : 'Client name is required';
    }
    update();
  }

  bool validateAllFields() {
    validateClientName();
    validateProblemFields();

    if (hasProblem.value) {
      if (selectedProblemType.value == 'No Name') {
        return isProblemTypeValid.value && isImageCaptured.value;
      } else {
        return isClientNameValid.value &&
            isProblemTypeValid.value &&
            isOtherProblemValid.value &&
            isImageCaptured.value;
      }
    } else {
      return isClientNameValid.value;
    }
  }

  // Dependencies
  final PackageRepository repository;
  final ImageService imageService;
  final ClientService clientService;
  final DialogService dialogService;

  PackageDetailsController(this.repository)
      : imageService = ImageService(),
        clientService = ClientService(),
        dialogService = DialogService();

  // TextEditing Controllers
  late TextEditingController clientNameController;

  // Observables
  final RxBool isClientNameValid = true.obs;
  final RxString clientNameError = ''.obs;
  final RxBool duplicateFound = false.obs;
  final RxString note = ''.obs;
  final RxBool isImageCaptured = false.obs;
  final Rx<File?> capturedImage = Rx<File?>(null);
  final RxBool isSaving = false.obs;
  final RxString packageStatus = ''.obs;
  final RxBool showUnknownCarrier = true.obs;
  final RxBool showCameraButton = true.obs;
  final RxList<String> clientSuggestions = <String>[].obs;
  final RxBool showSuggestions = true.obs;

  // Non-observable properties
  late String barcodeResult;
  late String location;
  late String userID;
  late StatusResult statusRequest;
  late String logistic;
  late String displayTrackingNumber;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    _setupControllers();
    _loadInitialData();
    _setupListeners();
  }

  void _setupControllers() {
    clientNameController = TextEditingController();
  }

  void _loadInitialData() {
    barcodeResult = Get.arguments?['barcodeResult'] ?? '';
    location = Get.arguments['location'];
    userID = Get.arguments['userID'];
    statusRequest = StatusResult.none;

    logistic = TrackingNumberService.getLogisticResult(barcodeResult);
    displayTrackingNumber =
        TrackingNumberService.getDisplayTrackingNumber(logistic, barcodeResult);

    checkIfPackageExists();
    clientService.loadClients();
  }

  void _setupListeners() {
    clientNameController.addListener(_onClientNameChanged);
  }

  Future<void> onRefresh() async {
    _resetPackageStatus();
    await checkIfPackageExists();
  }

  void _resetPackageStatus() {
    duplicateFound.value = false;
    note.value = 'This package has already been scanned.';
    isImageCaptured.value = false;
    capturedImage.value = null;
  }

  Future<PackageCheckResult> checkIfPackageExists() async {
    statusRequest = StatusResult.loading;
    update();

    try {
      String internalTrackingNumber = _getInternalTrackingNumber();
      PackageCheckResult result =
          await repository.checkPackageExists(internalTrackingNumber);
      _updatePackageStatus(result);
      return result;
    } catch (e) {
      _handleCheckPackageError();
      return PackageCheckResult(StatusResult.failure);
    }
  }

  String _getInternalTrackingNumber() {
    String carrier = TrackingNumberService.getLogisticResult(barcodeResult);
    String displayedTrackingNumber =
        TrackingNumberService.getDisplayTrackingNumber(carrier, barcodeResult);
    return TrackingNumberService.getInternalTrackingNumber(
        carrier, displayedTrackingNumber);
  }

  void _updatePackageStatus(PackageCheckResult result) {
    duplicateFound.value = (result.result == StatusResult.duplicateFound);
    note.value = result.note ?? '';
    packageStatus.value = (result.status ?? '').toLowerCase();
    showUnknownCarrier.value = packageStatus.value != 'pending';
    showCameraButton.value = packageStatus.value != 'pending';
    showDuplicateWarning.value =
        duplicateFound.value && packageStatus.value != 'pending';
    statusRequest = result.result;
    update();
  }

  void _handleCheckPackageError() {
    statusRequest = StatusResult.failure;
    update();
  }

  Future<void> processAndSavePackage({bool exitAfterSave = true}) async {
    if (isSaving.value) return;

    if (!validateAllFields()) {
      String errorMessage = '';

      if (hasProblem.value && !isImageCaptured.value) {
        errorMessage += 'Please take a photo of the damaged package.\n';
      }

      if (errorMessage.isNotEmpty) {
        SnackbarService.showCustomSnackbar(
          title: "Validation Error",
          message: errorMessage.trim(),
          backgroundColor: Colors.red,
        );
      }
      return;
    }

    bool shouldContinue = await _handleUnknownCarrier();
    if (!shouldContinue) return;

    if (hasProblem.value) {
      bool? confirm =
          await DialogService().showDamagedPackageConfirmationDialog();

      if (confirm != true) return;
    }

    isSaving.value = true;

    try {
      await _savePackage(exitAfterSave);
    } catch (e) {
      _handleSaveError();
    } finally {
      isSaving.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<bool> _handleUnknownCarrier() async {
    String carrier = TrackingNumberService.getLogisticResult(barcodeResult);
    bool isPending = packageStatus.value.toLowerCase() == 'pending';

    if (carrier == 'Unknown' && !isImageCaptured.value && !isPending) {
      bool? shouldTakePhoto = await dialogService.showPhotoConfirmationDialog();
      if (shouldTakePhoto == null) {
        return false;
      }
      if (shouldTakePhoto) {
        await takePhoto();
        if (!isImageCaptured.value) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _savePackage(bool exitAfterSave) async {
    EasyLoading.show(status: 'Processing...');

    String? photoUrl = await _uploadPhotoIfCaptured();
    PackageModel package = _createPackageModel();
    if (package.status == 'Roatan') {
      StatusResult result = await repository.savePackageRoatan(
        package,
        userID,
        photoUrl: photoUrl,
        isDamaged: hasProblem.value,
        problemType: selectedProblemType.value,
      );
      _handleSaveResult(result, exitAfterSave);
    } else {
      StatusResult result = await repository.savePackage(
        package,
        userID,
        photoUrl: photoUrl,
        isDamaged: hasProblem.value,
        problemType: selectedProblemType.value,
      );
      _handleSaveResult(result, exitAfterSave);
    }
  }

  Future<String?> _uploadPhotoIfCaptured() async {
    if (isImageCaptured.value && capturedImage.value != null) {
      return await imageService.uploadImage(capturedImage.value!);
    }
    return null;
  }

  PackageModel _createPackageModel() {
    String carrier = TrackingNumberService.getLogisticResult(barcodeResult);
    String displayedTrackingNumber =
        TrackingNumberService.getDisplayTrackingNumber(carrier, barcodeResult);
    String internalTrackingNumber =
        TrackingNumberService.getInternalTrackingNumber(
            carrier, displayedTrackingNumber);

    return PackageModel(
      rawTrackingNumber: displayedTrackingNumber,
      trackingNumber: internalTrackingNumber,
      carrier: carrier,
      status: location,
      clientName: hasProblem.value && selectedProblemType.value == 'No Name'
          ? null
          : clientNameController.text,
      note: note.value,
    );
  }

  void _handleSaveResult(StatusResult result, bool exitAfterSave) {
    if (result == StatusResult.success) {
      if (exitAfterSave) {
        Get.back(result: {'result': 'success'});
      } else {
        resetController();
        Get.back(result: {'action': 'rescan'});
      }
    } else if (result == StatusResult.notFound) {
      SnackbarService.showCustomSnackbar(
          title: "No Record Found",
          message:
              "This package doesn't have a record in our system. Please check the tracking number or scan again.",
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4));
    } else {
      SnackbarService.showCustomSnackbar(
        title: "Error",
        message: "Failed to save package. Please try again.",
        backgroundColor: Colors.red,
      );
    }
  }

  void _handleSaveError() {
    SnackbarService.showCustomSnackbar(
      title: "Error",
      message: "An unexpected error occurred. Please try again.",
    );
  }

  Future<void> takePhoto() async {
    File? image = await imageService.takePhoto();
    if (image != null) {
      capturedImage.value = image;
      isImageCaptured.value = true;
      update();
    }
  }

  void _onClientNameChanged() {
    final query = clientNameController.text.toLowerCase();
    clientSuggestions.value =
        query.isEmpty ? [] : clientService.getSuggestions(query);
    showSuggestions.value = isTextFieldFocused.value;
    validateClientName();
  }

  void selectClientName(String name) {
    clientNameController.text = name;
    clientSuggestions.clear();
    showSuggestions.value = false;
    isTextFieldFocused.value = false;
    validateClientName();
    update();
  }

  void onReScan() {
    Get.back(result: {'action': 'rescan'});
  }

  void resetController() {
    clientNameController.clear();
    isClientNameValid.value = true;
    clientNameError.value = '';
    duplicateFound.value = false;
    note.value = '';
    isImageCaptured.value = false;
    capturedImage.value = null;
    packageStatus.value = '';
    showUnknownCarrier.value = true;
    showCameraButton.value = true;
    update();
  }

  @override
  void onClose() {
    otherProblemController.dispose();
    clientNameController.removeListener(_onClientNameChanged);
    clientNameController.dispose();
    super.onClose();
  }
}
