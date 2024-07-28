// file: lib/features/consolidation/presentation/controller/package_photo_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:max_inventory_scanner/core/services/image_service.dart';

class PackagePhotoController extends GetxController {
  final ImageService imageService;
  final RxBool isImageCaptured = false.obs;
  final Rx<File?> capturedImage = Rx<File?>(null);
  final Rx<String?> selectedProblemType = Rx<String?>(null);
  final RxBool showOtherProblemField = false.obs;
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

}