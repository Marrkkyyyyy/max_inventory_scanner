import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/class/firestore_services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../utils/snackbar_service.dart';
import '../../class/service_result.dart';

class ConsolidationProcessController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  String? barcodeResult;
  RxList<String> detectedBarcodes = <String>[].obs;
  final TextEditingController trackingNumberController =
      TextEditingController();
  RxBool isConsolidating = false.obs;

  @override
  void onInit() {
    barcodeResult = Get.arguments['barcodeResult'];
    super.onInit();
  }

  @override
  void onClose() {
    trackingNumberController.dispose();
    super.onClose();
  }

  void removeDetectedBarcode(int index) {
    detectedBarcodes.removeAt(index);
  }

  bool addDetectedBarcode(String barcode) {
    if (barcode == barcodeResult) {
      SnackbarService.showCustomSnackbar(
        title: 'Invalid Tracking Number',
        message:
            'The scanned tracking number is the same as the consolidation tracking number.',
        backgroundColor: Colors.red,
      );
      return false;
    }
    if (detectedBarcodes.contains(barcode)) {
      SnackbarService.showCustomSnackbar(
        title: 'Duplicate Tracking Number',
        message:
            'This tracking number has already been added to the consolidation.',
        backgroundColor: Colors.red,
      );
      return false;
    } else {
      detectedBarcodes.add(barcode);
      return true;
    }
  }

  Future<void> consolidatePackages() async {
    if (isConsolidating.value) {
      return;
    }

    if (detectedBarcodes.isEmpty) {
      SnackbarService.showCustomSnackbar(
        title: 'No Packages to Consolidate',
        message: 'Please add packages to consolidate.',
        backgroundColor: Colors.red,
      );
      return;
    }

    isConsolidating.value = true;
    EasyLoading.show(status: 'Consolidating packages...');

    try {
      PackageResult result = await _firestoreService.consolidatePackages(
        newConsolidatedTrackingNumber: barcodeResult!,
        trackingNumbersToConsolidate: detectedBarcodes,
      );

      switch (result) {
        case PackageResult.success:
          EasyLoading.dismiss();
          EasyLoading.showSuccess('Consolidation Successful',
              duration: const Duration(seconds: 2));
          await Future.delayed(const Duration(seconds: 2));
          Get.back();
          break;
        case PackageResult.noInternet:
          EasyLoading.dismiss();
          SnackbarService.showCustomSnackbar(
            title: 'No Internet Connection',
            message: 'Please check your internet connection and try again.',
            backgroundColor: Colors.red,
          );
          break;
        case PackageResult.failure:
          EasyLoading.dismiss();
          SnackbarService.showCustomSnackbar(
            title: 'Consolidation Failed',
            message:
                'An error occurred during consolidation. Please try again.',
            backgroundColor: Colors.red,
          );
          break;
        case PackageResult.notFound:
          EasyLoading.dismiss();
          SnackbarService.showCustomSnackbar(
            title: "Consolidation Failed",
            message:
                "Some packages were not found or are not in received status",
            backgroundColor: Colors.red,
          );
          break;
        default:
          EasyLoading.dismiss();
          break;
      }
    } finally {
      isConsolidating.value = false;
    }
  }
}
