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
  final TextEditingController otherProblemController = TextEditingController();

  // Observable variables
  final RxBool showDuplicateWarning = false.obs;
  final RxBool isTextFieldFocused = false.obs;
  final RxBool isProblemTypeValid = true.obs;
  final RxBool isOtherProblemValid = true.obs;
  final RxBool isPhotoRequired = false.obs;
  final RxBool hasProblem = false.obs;
  final RxBool isUnknownCarrier = false.obs;
  final Rx<String?> selectedProblemType = Rx<String?>(null);
  final RxBool showOtherProblemField = false.obs;
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
  final RxBool isNameInClientList = true.obs;
  final RxString nameNotInListWarning = ''.obs;
  final RxBool isWarningVisible = false.obs;
  final RxBool shouldUploadPhoto = false.obs;

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

    isUnknownCarrier.value = (logistic == 'Unknown');
    if (isUnknownCarrier.value) {
      hasProblem.value = true;
      isPhotoRequired.value = true;
    }

    checkIfPackageExists();
    clientService.loadClients();
  }

  void _setupListeners() {
    clientNameController.addListener(onClientNameChanged);
  }

  // Problem handling methods
  void toggleProblem(bool? value) {
    hasProblem.value = value ?? false;
    if (!hasProblem.value) {
      selectedProblemType.value = null;
      showOtherProblemField.value = false;
      otherProblemController.clear();
      isPhotoRequired.value = false;
      shouldUploadPhoto.value = false;
    } else {
      isPhotoRequired.value = true;
      shouldUploadPhoto.value = isImageCaptured.value;
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
    isProblemTypeValid.value = true;
    isOtherProblemValid.value =
        !showOtherProblemField.value || otherProblemController.text.isNotEmpty;
    update();
  }

  // Package existence check methods
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

    validateClientName();

    if (!isClientNameValid.value) {
      return;
    }

    if (!validateAllFields()) {
      if (hasProblem.value &&
          !isImageCaptured.value &&
          selectedProblemType.value != null &&
          selectedProblemType.value != 'No Problem Type Selected') {
        SnackbarService.showCustomSnackbar(
          title: "Validation Error",
          message: "Please take a photo of the package.",
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    if (hasProblem.value &&
        !isImageCaptured.value &&
        (selectedProblemType.value == null ||
            selectedProblemType.value == 'No Problem Type Selected')) {
      bool? shouldTakePhoto = await dialogService.showPhotoConfirmationDialog();
      if (shouldTakePhoto == null) {
        return;
      }
      if (shouldTakePhoto) {
        await takePhoto();
        if (!isImageCaptured.value) {
          return;
        }
      } else {
        return;
      }
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
    if (isImageCaptured.value &&
        capturedImage.value != null &&
        shouldUploadPhoto.value) {
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

  // Photo handling methods
  Future<void> takePhoto() async {
    File? image = await imageService.takePhoto();
    if (image != null) {
      capturedImage.value = image;
      isImageCaptured.value = true;
      shouldUploadPhoto.value = hasProblem.value;
      update();
    }
  }

  // Client name handling methods
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
      isWarningVisible.value = false; // Don't show warning while typing
    } else {
      nameNotInListWarning.value = '';
      isWarningVisible.value = false;
    }

    validateClientName();
  }

  void validateClientName() {
    if (hasProblem.value && selectedProblemType.value == 'No Name') {
      isClientNameValid.value = true;
      clientNameError.value = '';
      nameNotInListWarning.value = '';
      isWarningVisible.value = false;
    } else {
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
    }
    update();
  }

  void onClientNameSubmitted() {
    isTextFieldFocused.value = false;
    validateClientName();
    update();
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
    clientSuggestions.clear();
    showSuggestions.value = false;
    isTextFieldFocused.value = false;
    validateClientName();
    update();
  }

  bool validateAllFields() {
    validateClientName();
    validateProblemFields();

    if (hasProblem.value) {
      if (selectedProblemType.value == 'No Name') {
        return isImageCaptured.value;
      } else {
        return isClientNameValid.value &&
            isOtherProblemValid.value &&
            isImageCaptured.value;
      }
    } else {
      return isClientNameValid.value;
    }
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
    clientNameController.removeListener(onClientNameChanged);
    clientNameController.dispose();
    super.onClose();
  }
}
