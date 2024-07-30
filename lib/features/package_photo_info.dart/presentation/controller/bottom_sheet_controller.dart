import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/model/package_photo_info_model.dart';

class BarcodeDetectedBottomSheetController extends GetxController {
  final Future<List<PackagePhotoInfo>> Function(String) photoInfoFetcher;
  final _consolidationRepository =
      ConsolidationRepositoryImpl(Get.find<FirebaseFirestore>());
  final RxList<PackagePhotoInfo> photoInfoList = <PackagePhotoInfo>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isPackageExist = true.obs;
  final String trackingNumber;
  final bool packageExists;
  final bool shouldCheckExistence;

  BarcodeDetectedBottomSheetController({
    required this.photoInfoFetcher,
    required this.trackingNumber,
    required this.packageExists,
    required this.shouldCheckExistence,
  });

  Future<bool> checkPackageExistence(String barcode) async {
    final existsFuture = _consolidationRepository.isPackageExisting(barcode);
    final delayFuture = Future.delayed(const Duration(seconds: 2));
    final List<dynamic> results =
        await Future.wait([existsFuture, delayFuture]);
    return results[0] as bool;
  }

  Future<void> loadPhotoInfo() async {
    final photos = await photoInfoFetcher(trackingNumber);
    photoInfoList.assignAll(photos);
  }

  Future<void> initializeData() async {
    if (!shouldCheckExistence) {
      isLoading.value = false;
      isPackageExist.value = false;
      return;
    }

    try {
      await EasyLoading.show(status: 'Loading...', dismissOnTap: false);

      List<Future> futures = [loadPhotoInfo()];

      if (!packageExists) {
        futures.add(checkPackageExistence(trackingNumber));
      }
      futures.add(Future.delayed(const Duration(seconds: 2)));

      final List<dynamic> results = await Future.wait(futures);

      if (!packageExists) {
        bool packageExistsCheck = results[1] as bool;
        isPackageExist.value = packageExistsCheck;
      } else {
        isPackageExist.value = packageExists;
      }
    } finally {
      await EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }
}
