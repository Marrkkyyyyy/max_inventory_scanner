import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/services/shared_preferences_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/manual_tracking_number.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class ConsolidationController extends GetxController {
  final SharedPreferencesService _sharedPreferencesService =
      Get.find<SharedPreferencesService>();

  final TrackingNumberSearchService _trackingNumberSearchService;

  ConsolidationController(this._trackingNumberSearchService);

  final RxList<String> trackingSuggestions = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString name = ''.obs;
  final RxString location = ''.obs;
  final RxString userID = ''.obs;
  final TextEditingController manualTrackingNumberController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    manualTrackingNumberController.dispose();
    super.onClose();
  }

  void loadUserData() {
    name.value = _sharedPreferencesService.getName() ?? '';
    location.value = _sharedPreferencesService.getLocation() ?? '';
    userID.value = _sharedPreferencesService.getUserID() ?? '';
  }

  Future<void> searchTrackingNumbers(String query) async {
    isLoading.value = true;
    List<String> results =
        await _trackingNumberSearchService.searchTrackingNumbers(query);
    trackingSuggestions.assignAll(results);
    isLoading.value = false;
  }

  void showConsolidationScanner(BuildContext context,
      {required bool isNewBox}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          navigateToConsolidation(context,
              barcode: barcode, isNewBox: isNewBox);
        },
      ),
    ));
  }

  void showManualEntryDialog(BuildContext context, {required bool isNewBox}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext context) {
        return isNewBox
            ? TrackingNumberEntryModal(
                isLoading: false.obs,
                onAdd: (val) {
                  Navigator.of(context).pop();
                  navigateToConsolidation(context,
                      barcode: manualTrackingNumberController.text,
                      isNewBox: isNewBox);
                  manualTrackingNumberController.clear();
                },
                textEditingController: manualTrackingNumberController,
                trackingSuggestions: [''].obs,
                showSuggestions: false,
                onSearch: (val) {},
              )
            : TrackingNumberEntryModal(
                onAdd: (val) {
                  Navigator.of(context).pop();
                  navigateToConsolidation(context,
                      barcode: manualTrackingNumberController.text,
                      isNewBox: isNewBox);
                  manualTrackingNumberController.clear();
                },
                textEditingController: manualTrackingNumberController,
                trackingSuggestions: trackingSuggestions,
                isLoading: isLoading,
                onSearch: searchTrackingNumbers,
              );
      },
    );
  }

  void navigateToConsolidation(BuildContext context,
      {required String barcode, required bool isNewBox}) {
    Get.toNamed(AppRoute.CONSOLIDATION_PROCCESS, arguments: {
      "barcodeResult": barcode,
      "location": location.value,
      "isNewBox": isNewBox,
    });
  }
}
