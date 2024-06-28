// home_page_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/functions/carrier_and_tracking_number.dart';
import '../../class/firestore_services.dart';
import '../../class/service_result.dart';

class HomePageController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final RxList<String> dropdownItems =
      <String>['Receiving', 'Container', 'Roatan'].obs;
  final RxString selectedItem = 'Receiving'.obs;
  final TextEditingController trackingNumberController =
      TextEditingController();
  RxBool isSaving = false.obs;

  Future<String> getLogisticResult(String barcode) async {
    return await identifyCourier(barcode) ?? 'Unknown';
  }

  Future<String> getDisplayTrackingNumber(
      String logistic, String barcode) async {
    if (logistic == 'USPS') {
      return cleanBarcode(barcode);
    }
    return barcode;
  }

  Future<String> getInternalTrackingNumber(
      String logistic, String displayedNumber) async {
    if (logistic == 'FedEx' && displayedNumber.length >= 12) {
      return displayedNumber.substring(displayedNumber.length - 12);
    }
    return displayedNumber;
  }

  Future<PackageResult> processAndSavePackage(String barcode) async {
    if (isSaving.value) {
      return PackageResult.failure;
    }
    isSaving.value = true;
    EasyLoading.show(status: 'Processing...');
    try {
      String carrier = await getLogisticResult(barcode);
      String displayedTrackingNumber =
          await getDisplayTrackingNumber(carrier, barcode);
      String internalTrackingNumber =
          await getInternalTrackingNumber(carrier, displayedTrackingNumber);

      PackageResult result = await firestoreService.savePackage(
        carrier: carrier,
        rawTrackingNumber: internalTrackingNumber,
        trackingNumber: internalTrackingNumber,
      );

      return result;
    } catch (e) {
      return PackageResult.failure;
    } finally {
      isSaving.value = false;
      EasyLoading.dismiss();
    }
  }

  void setSelectedItem(String value) {
    selectedItem.value = value;
  }

  @override
  void onClose() {
    trackingNumberController.dispose();
    super.onClose();
  }
}
