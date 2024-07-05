import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:max_inventory_scanner/core/functions/carrier_and_tracking_number.dart';
import 'package:max_inventory_scanner/core/services/services.dart';
import 'package:max_inventory_scanner/routes.dart';
import 'package:max_inventory_scanner/utils/snackbar_service.dart';
import '../../class/firestore_services.dart';
import '../../class/service_result.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomePageController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final MyServices _myServices = Get.find<MyServices>();

  RxBool isSaving = false.obs;

  final List<String> issueItems = ['Damaged', 'No Name', 'No Address', 'Other'];
  final RxString imagePath = ''.obs;
  final RxString selectedIssue = ''.obs;
  late TextEditingController trackingNumberController;
  late TextEditingController otherIssueController;
  late TextEditingController reportTrackingNumberController;

  final RxString name = ''.obs;
  final RxString location = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkSettings();
    trackingNumberController = TextEditingController();
    otherIssueController = TextEditingController();
    reportTrackingNumberController = TextEditingController();
  }

  void checkSettings() {
    name.value = _myServices.getName() ?? '';
    location.value = _myServices.getLocation() ?? '';

    if (name.isEmpty || location.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoute.settingsPage)!.then((_) {
          name.value = _myServices.getName() ?? '';
          location.value = _myServices.getLocation() ?? '';
          isLoading.value = false;
        });
      });
    } else {
      isLoading.value = false;
    }
  }

  Future<PackageResult> processAndSavePackage(String barcode) async {
    if (isSaving.value) return PackageResult.failure;
    isSaving.value = true;
    EasyLoading.show(status: 'Processing...');
    try {
      String carrier = await getLogisticResult(barcode);
      String displayedTrackingNumber =
          await getDisplayTrackingNumber(carrier, barcode);
      String internalTrackingNumber =
          await getInternalTrackingNumber(carrier, displayedTrackingNumber);

      return await firestoreService.savePackage(
          carrier: carrier,
          rawTrackingNumber: displayedTrackingNumber,
          trackingNumber: internalTrackingNumber,
          status: location.value);
    } catch (e) {
      return PackageResult.failure;
    } finally {
      isSaving.value = false;
      EasyLoading.dismiss();
    }
  }

  void detectBarcode(String barcode) {
    reportTrackingNumberController.text = barcode;
  }

  Future<void> takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagePath.value = image.path;
    }
  }

  void setSelectedIssue(String? issue) {
    selectedIssue.value = issue ?? '';
  }

  Future<void> reportIssue() async {
    if (selectedIssue.isEmpty ||
        imagePath.isEmpty ||
        reportTrackingNumberController.text.isEmpty) {
      SnackbarService.showCustomSnackbar(
          title: 'Error',
          message: 'Please fill all required fields and take a picture');

      return;
    }

    if (selectedIssue.value == 'Other' &&
        otherIssueController.text.trim().isEmpty) {
      SnackbarService.showCustomSnackbar(
          title: 'Error', message: 'Please specify the issue');
      return;
    }

    EasyLoading.show(status: 'Reporting issue...');

    try {
      String issue = selectedIssue.value;
      String problemType =
          issue == 'Other' ? otherIssueController.text.trim() : issue;

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
          dir.absolute.path, 'compressed_${path.basename(imagePath.value)}');

      XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        imagePath.value,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedXFile == null) {
        throw Exception('Failed to compress image');
      }

      File compressedFile = File(compressedXFile.path);

      PackageResult result = await firestoreService.reportIssue(
        trackingNumber: reportTrackingNumberController.text,
        problemType: problemType,
        imageFile: compressedFile,
      );

      if (result == PackageResult.success) {
        SnackbarService.showCustomSnackbar(
            title: 'Success',
            message: 'Issue reported successfully',
            backgroundColor: Colors.teal.shade400);
      } else if (result == PackageResult.noInternet) {
        SnackbarService.showCustomSnackbar(
            title: 'Error', message: 'No internet connection');
      } else {
        SnackbarService.showCustomSnackbar(
            title: 'Error', message: 'Failed to report issue');
      }
    } catch (e) {
      SnackbarService.showCustomSnackbar(
          title: 'Error', message: 'An unexpected error occurred');
    } finally {
      EasyLoading.dismiss();

      imagePath.value = '';
      selectedIssue.value = '';
      otherIssueController.clear();
      reportTrackingNumberController.clear();
    }
  }

  Future<void> canelReportIssue() async {
    imagePath.value = '';
    selectedIssue.value = '';
    otherIssueController.clear();
    reportTrackingNumberController.clear();
  }

  void resetTrackingNumberController() {
    trackingNumberController.clear();
    otherIssueController.clear();
    reportTrackingNumberController.clear();
  }
}
