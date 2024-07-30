// file: lib/features/consolidation/presentation/controller/package_photo_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:max_inventory_scanner/core/services/image_service.dart';

class PackagePhotoController extends GetxController {
  // Dependencies
  final ImageService imageService;

  // Observables
  final RxBool isImageCaptured = false.obs;
  final Rx<File?> capturedImage = Rx<File?>(null);
  final Rx<String?> selectedProblemType = Rx<String?>(null);
  final RxBool showOtherProblemField = false.obs;

  // Controllers
  final TextEditingController otherProblemController = TextEditingController();

  PackagePhotoController(this.imageService);

  @override
  void onClose() {
    otherProblemController.dispose();
    super.onClose();
  }

  void clearPhoto() {
    capturedImage.value = null;
    isImageCaptured.value = false;
    clearProblemData();
    update();
  }

  void clearProblemData() {
    selectedProblemType.value = null;
    showOtherProblemField.value = false;
    otherProblemController.clear();
  }

  Future<void> takePhoto() async {
    final File? image = await imageService.takePhoto();
    if (image != null) {
      capturedImage.value = image;
      isImageCaptured.value = true;
    } else {
      isImageCaptured.value = false;
    }
    update();
  }

  void setProblemType(String? type) {
    selectedProblemType.value = type;
    showOtherProblemField.value = type == 'Other';
    if (type != 'Other') {
      otherProblemController.clear();
    }
    update();
  }

  bool get hasPhoto => isImageCaptured.value && capturedImage.value != null;

  bool get hasProblemData =>
      selectedProblemType.value != null ||
      otherProblemController.text.isNotEmpty;
}
