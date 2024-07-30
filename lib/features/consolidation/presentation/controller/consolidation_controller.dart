import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/services/shared_preferences_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/manual_tracking_number.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class ConsolidationController extends GetxController {
  // Dependencies
  final SharedPreferencesService _sharedPreferencesService =
      Get.find<SharedPreferencesService>();
  final TrackingNumberSearchService _trackingNumberSearchService;
  final ConsolidationRepository _consolidationRepository;

  // Observables
  final RxList<String> trackingSuggestions = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString name = ''.obs;
  final RxString location = ''.obs;
  final RxString userID = ''.obs;
  final RxBool searchCompleted = false.obs;

  // Controllers
  final TextEditingController manualTrackingNumberController =
      TextEditingController();

  ConsolidationController(
      this._trackingNumberSearchService, this._consolidationRepository);

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
    searchCompleted.value = false;
    List<String> results = await _trackingNumberSearchService
        .searchTrackingNumbers(query, location.value);
    trackingSuggestions.assignAll(results);
    isLoading.value = false;
    searchCompleted.value = true;
  }

  void showConsolidationScanner(BuildContext context,
      {required bool isNewBox}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CustomScanner(
        onBarcodeDetected: (barcode) =>
            _handleBarcodeDetection(context, barcode, isNewBox),
      ),
    ));
  }

  void showManualEntryDialog(BuildContext context, {required bool isNewBox}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext context) =>
          _buildTrackingNumberEntryModal(context, isNewBox),
    );
  }

  Widget _buildTrackingNumberEntryModal(BuildContext context, bool isNewBox) {
    return TrackingNumberEntryModal(
      isLoading: isLoading,
      onAdd: (val, {bool? isSuggestionSelected}) =>
          _handleManualEntry(context, val, isNewBox, isSuggestionSelected),
      textEditingController: manualTrackingNumberController,
      trackingSuggestions: isNewBox ? [''].obs : trackingSuggestions,
      showSuggestions: !isNewBox,
      onSearch: isNewBox ? (val) {} : searchTrackingNumbers,
    );
  }

  void _handleBarcodeDetection(
      BuildContext context, String barcode, bool isNewBox) {
    Navigator.of(context).pop();
    checkAndNavigateToConsolidation(context,
        barcode: barcode, isNewBox: isNewBox, isSuggestionSelected: false);
  }

  void _handleManualEntry(BuildContext context, String val, bool isNewBox,
      bool? isSuggestionSelected) {
    Navigator.of(context).pop();
    checkAndNavigateToConsolidation(
      context,
      barcode: val,
      isNewBox: isNewBox,
      isSuggestionSelected: isSuggestionSelected ?? false,
    );
    manualTrackingNumberController.clear();
  }

  Future<void> checkAndNavigateToConsolidation(
    BuildContext context, {
    required String barcode,
    required bool isNewBox,
    required bool isSuggestionSelected,
  }) async {
    bool packageExists = true;
    bool shouldCheckExistence = isLoading.value ||
        !searchCompleted.value ||
        (searchCompleted.value && trackingSuggestions.isNotEmpty);

    if (shouldCheckExistence && !isNewBox && !isSuggestionSelected) {
      await EasyLoading.show(status: 'Checking package...');
      packageExists = await _consolidationRepository.isPackageExisting(barcode);
      await EasyLoading.dismiss();
    }

    navigateToConsolidation(
      context,
      barcode: barcode,
      isNewBox: isNewBox,
      packageExists: packageExists,
      shouldCheckExistence: shouldCheckExistence,
    );
  }

  void navigateToConsolidation(
    BuildContext context, {
    required String barcode,
    required bool isNewBox,
    required bool packageExists,
    required bool shouldCheckExistence,
  }) {
    bool finalPackageExists = shouldCheckExistence ? packageExists : false;

    Get.toNamed(
      AppRoute.CONSOLIDATION_PROCCESS,
      arguments: {
        "barcodeResult": barcode,
        "location": location.value,
        "isNewBox": isNewBox,
        "packageExists": finalPackageExists,
        "shouldCheckExistence": shouldCheckExistence,
      },
    );
  }
}
