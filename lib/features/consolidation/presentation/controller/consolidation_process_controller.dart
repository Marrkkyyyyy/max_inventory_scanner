// file: lib/features/consolidation/presentation/controller/consolidation_process_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/image_service.dart';
import 'package:max_inventory_scanner/core/services/shared_preferences_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/repository/package_photo_repository.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/barcode_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/measurement_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/package_photo_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/tracking_number_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/image_view.dart';

class ConsolidationProcessController extends GetxController {
  // Dependencies
  final SharedPreferencesService _myServices =
      Get.find<SharedPreferencesService>();
  final ConsolidationRepository _consolidationRepository;
  final PackagePhotoRepository _packagePhotoRepository;
  final TrackingNumberSearchService _trackingNumberSearchService;
  final ImageService imageService;

  // Sub-controllers
  late final MeasurementController measurementController;
  late final TrackingNumberController trackingNumberController;
  late final PackagePhotoController packagePhotoController;
  late final BarcodeController barcodeController;

  // Observables
  final RxString barcodeResult = ''.obs;
  final RxBool isNewBox = false.obs;
  final RxString location = ''.obs;
  final RxBool packageExists = true.obs;
  final Rx<File?> capturedImage = Rx<File?>(null);
  final RxBool isImageCaptured = false.obs;
  final RxBool shouldCheckExistence = true.obs;

  ConsolidationProcessController(
    this._consolidationRepository,
    this._trackingNumberSearchService,
    this._packagePhotoRepository,
  ) : imageService = ImageService();

  @override
  void onInit() {
    super.onInit();
    _initializeSubControllers();
    _loadInitialData();
  }

  void _initializeSubControllers() {
    measurementController = Get.put(MeasurementController(this));
    packagePhotoController = Get.find<PackagePhotoController>();
    barcodeController = Get.put(BarcodeController(
        this, _packagePhotoRepository, packagePhotoController));
    trackingNumberController =
        Get.put(TrackingNumberController(this, _trackingNumberSearchService));
  }

  void _loadInitialData() {
    barcodeResult.value = Get.arguments['barcodeResult'];
    isNewBox.value = Get.arguments['isNewBox'];
    packageExists.value = Get.arguments['packageExists'];
    location.value = _myServices.getLocation() ?? '';
    shouldCheckExistence.value = Get.arguments['shouldCheckExistence'] ?? true;
  }

  Future<void> takePhoto() async {
    final File? image = await imageService.takePhoto();
    if (image != null) {
      capturedImage.value = image;
      isImageCaptured.value = true;
      update();
    }
  }

  void showImageViewDialog(
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
}
