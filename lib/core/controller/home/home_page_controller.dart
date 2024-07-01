import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:max_inventory_scanner/core/functions/carrier_and_tracking_number.dart';
import '../../class/firestore_services.dart';
import '../../class/service_result.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomePageController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final RxList<String> dropdownItems =
      <String>['Receiving', 'Container', 'Roatan'].obs;
  final RxString selectedLocation = 'Receiving'.obs;
  final TextEditingController trackingNumberController =
      TextEditingController();
  RxBool isSaving = false.obs;

  final List<String> issueItems = ['Damaged', 'No Name', 'No Address', 'Other'];
  final RxString imagePath = ''.obs;
  final RxString selectedIssue = ''.obs;
  final TextEditingController otherIssueController = TextEditingController();
  final TextEditingController reportTrackingNumberController =
      TextEditingController();

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
          status: selectedLocation.value);
    } catch (e) {
      return PackageResult.failure;
    } finally {
      isSaving.value = false;
      EasyLoading.dismiss();
    }
  }

  void setSelectedItem(String value) {
    selectedLocation.value = value;
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
      Get.snackbar(
          'Error', 'Please fill all required fields and take a picture');
      return;
    }

    EasyLoading.show(status: 'Reporting issue...');

    try {
      String issue = selectedIssue.value;
      String problemType = issue == 'Other' ? otherIssueController.text : issue;

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
        Get.snackbar('Success', 'Issue reported successfully');
      } else if (result == PackageResult.noInternet) {
        Get.snackbar('Error', 'No internet connection');
      } else {
        Get.snackbar('Error', 'Failed to report issue');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}');
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

  @override
  void onClose() {
    trackingNumberController.dispose();
    otherIssueController.dispose();
    reportTrackingNumberController.dispose();
    super.onClose();
  }
}
