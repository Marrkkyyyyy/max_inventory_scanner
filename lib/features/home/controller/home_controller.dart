import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/services/shared_preferences_service.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class HomeController extends GetxController {
  final SharedPreferencesService _myServices =
      Get.find<SharedPreferencesService>();
  final TrackingNumberSearchService _trackingNumberSearchService;
  HomeController(this._trackingNumberSearchService);
  final RxString name = ''.obs;
  final RxString location = ''.obs;
  final RxString userID = ''.obs;
  final RxBool isLoading = true.obs;
  final TextEditingController trackingNumberController =
      TextEditingController();
  final TextEditingController manualTrackingNumberController =
      TextEditingController();

  final RxList<String> trackingSuggestions = <String>[].obs;
  final RxBool isLoadingSearch = false.obs;

  Future<void> searchTrackingNumbers(String query) async {
    isLoadingSearch.value = true;
    List<String> results = await _trackingNumberSearchService
        .searchTrackingNumbers(query, location.value);
    trackingSuggestions.assignAll(results);
    isLoadingSearch.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    checkSettings();
  }

  @override
  void onClose() {
    trackingNumberController.dispose();
    super.onClose();
  }

  void checkSettings() {
    name.value = _myServices.getName() ?? '';
    location.value = _myServices.getLocation() ?? '';
    userID.value = _myServices.getUserID() ?? '';

    if (name.isEmpty || location.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoute.SETTINGS)!.then((_) {
          name.value = _myServices.getName() ?? '';
          location.value = _myServices.getLocation() ?? '';
          isLoading.value = false;
        });
      });
    } else {
      isLoading.value = false;
    }
  }
}
