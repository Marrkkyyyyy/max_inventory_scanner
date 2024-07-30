import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/core/widgets/manual_tracking_number.dart';

class TrackingNumberController extends GetxController {
  final ConsolidationProcessController parentController;
  final TrackingNumberSearchService _trackingNumberSearchService;

  final RxList<String> trackingSuggestions = <String>[].obs;
  final RxBool isLoading = false.obs;

  final RxBool searchCompleted = false.obs;
  final TextEditingController trackingNumberController =
      TextEditingController();

  TrackingNumberController(
      this.parentController, this._trackingNumberSearchService);

  @override
  void onClose() {
    trackingNumberController.dispose();
    super.onClose();
  }

  Future<void> searchTrackingNumbers(String query) async {
    isLoading.value = true;
    searchCompleted.value = false;
    List<String> results = await _trackingNumberSearchService
        .searchTrackingNumbers(query, parentController.location.value);
    trackingSuggestions.assignAll(results);
    isLoading.value = false;
    searchCompleted.value = true;
  }

  void showTrackingNumberEntry(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (val, {bool? isSuggestionSelected}) {
          Navigator.of(context).pop();
          if (!parentController.barcodeController.checkBarcodeExists(val)) {
            trackingNumberController.clear();

            bool shouldCheckExistence = !searchCompleted.value ||
                (searchCompleted.value && trackingSuggestions.isNotEmpty);

            parentController.barcodeController.showBarcodeDetectedBottomSheet(
              context,
              PackageInfo(trackingNumber: val),
              null,
              isSuggestionSelected ?? false,
              shouldCheckExistence,
            );
          }
        },
        textEditingController: trackingNumberController,
        trackingSuggestions: trackingSuggestions,
        isLoading: isLoading,
        onSearch: searchTrackingNumbers,
      ),
    );
  }
}
