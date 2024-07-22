import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/strings.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/theme/text_styles.dart';
import 'package:max_inventory_scanner/core/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/tracking_number_entry_modal.dart';
import 'package:max_inventory_scanner/features/home/controller/home_controller.dart';
import 'package:max_inventory_scanner/features/home/presentation/widgets/action_button.dart';
import 'package:max_inventory_scanner/features/home/presentation/widgets/custom_header.dart';
import 'package:max_inventory_scanner/features/home/presentation/widgets/image_display.dart';

import 'package:max_inventory_scanner/routes/routes.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (controller.location.value == 'Consolidation') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRoute.CONSOLIDATION);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else {
        return Scaffold(
          backgroundColor: AppColor.white,
          appBar: AppBar(
            title: Text(
              AppStrings.appName,
              style: TextStyles.appBarTextStyle(
                textColor: AppColor.darkBlue,
              ),
            ),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: _buildHomePage(context),
        );
      }
    });
  }

  Widget _buildHomePage(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 20),
        child: Column(
          children: [
            customHeader(controller.name.value, controller.location.value),
            const SizedBox(height: 12),
            imageDisplay(),
            const SizedBox(height: 12),
            ActionButton(
              text: 'SCAN',
              icon: Icons.qr_code_scanner,
              color: AppColor.blue,
              onPressed: () => startScanProcess(context),
            ),
            const SizedBox(height: 12),
            ActionButton(
              text: 'MANUAL ENTRY',
              icon: Icons.keyboard_alt,
              color: AppColor.blue,
              onPressed: () => showTrackingNumberEntry(context),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  void showTrackingNumberEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (_) async {
          Get.back();
          manualEntry(controller.trackingNumberController.text);
          controller.trackingNumberController.clear();
          controller.update();
        },
        controller: controller.trackingNumberController,
      ),
    );
  }

  void manualEntry(String barcode) async {
    bool shouldRescan = true;
    while (shouldRescan) {
      shouldRescan = false;
      final navigationResult = await Get.toNamed(
        AppRoute.PACKAGE_DETAILS,
        arguments: {
          'barcodeResult': barcode,
          'location': controller.location.value,
          'userID': controller.userID.value
        },
      );

      if (navigationResult is Map && navigationResult['action'] == 'rescan') {
        shouldRescan = true;
        await startScanProcess(Get.context!);
        return;
      } else if (navigationResult is Map &&
          navigationResult['result'] == 'success') {
        SnackbarService.showCustomSnackbar(
            duration: const Duration(seconds: 1, milliseconds: 500),
            title: "Success",
            message: "Package saved successfully",
            backgroundColor: AppColor.teal);
      }
    }
  }

  startScanProcess(BuildContext context) async {
    bool shouldRescan = true;
    while (shouldRescan) {
      shouldRescan = false;
      final barcodeResult = await showDialog<String>(
        context: context,
        builder: (BuildContext context1) {
          return CustomScanner(
            onBarcodeDetected: (barcode) {
              Navigator.of(context1).pop(barcode);
            },
          );
        },
      );

      if (barcodeResult == null) {
        return;
      }

      final navigationResult = await Get.toNamed(
        AppRoute.PACKAGE_DETAILS,
        arguments: {
          'barcodeResult': barcodeResult,
          'location': controller.location.value,
          'userID': controller.userID.value
        },
      );

      if (navigationResult is Map && navigationResult['action'] == 'rescan') {
        shouldRescan = true;
      } else if (navigationResult is Map &&
          navigationResult['result'] == 'success') {
        SnackbarService.showCustomSnackbar(
            duration: const Duration(seconds: 1),
            title: "Success",
            message: "Package saved successfully",
            backgroundColor: AppColor.teal);
      }
    }
  }
}
