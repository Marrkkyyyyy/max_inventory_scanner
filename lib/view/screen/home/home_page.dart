import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/core/class/service_result.dart';
import 'package:max_inventory_scanner/routes.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';

import '../../../core/class/error_handler.dart';
import '../../../utils/snackbar_service.dart';
import '../../widget/home/action_button.dart';
import '../../widget/home/dropdown_selector.dart';
import '../../widget/home/image_display.dart';
import '../../widget/home/scan/modal_barcode_result.dart';
import '../../widget/tracking_number_entry_modal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePageController());

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColor.blue3,
        centerTitle: true,
        title: const Text("Max Inventory Scanner"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
          child: Column(
            children: [
              DropdownSelector(
                controller: controller,
              ),
              const SizedBox(height: 12),
              const ImageDisplay(),
              const SizedBox(height: 12),
              ActionButton(
                text: 'SCAN',
                icon: Icons.qr_code_scanner,
                color: AppColor.blue2,
                onPressed: () =>
                    _showScannerAndBottomSheet(context, controller),
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'MANUAL ENTRY',
                icon: Icons.keyboard_alt,
                color: AppColor.blue2,
                onPressed: () => showTrackingNumberEntry(context, controller),
                isOutlined: true,
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'CONSOLIDATION',
                icon: Icons.inventory_2_rounded,
                color: AppColor.blue2,
                onPressed: () => Get.toNamed(AppRoute.consolidationPage),
                isOutlined: true,
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'TAKE A PICTURE',
                icon: Icons.camera_alt,
                color: AppColor.darkRed,
                onPressed: () {},
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScannerAndBottomSheet(
      BuildContext context, HomePageController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScanner(
          onBarcodeDetected: (barcode) {
            Navigator.of(context).pop();
            _showBottomSheet(context, barcode, controller);
          },
        );
      },
    );
  }

  void _showBottomSheet(
      BuildContext context, String barcode, HomePageController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BarcodeBottomSheet(
          barcodeResult: barcode,
          onReScan: () {
            Navigator.of(context).pop();
            _showScannerAndBottomSheet(context, controller);
          },
          onSaveAndNext: () async {
            if (controller.isSaving.value) return;

            PackageResult result =
                await controller.processAndSavePackage(barcode);
            _handlePackageResult(result, context, controller);
          },
        );
      },
    );
  }

  void _handlePackageResult(
      PackageResult result, BuildContext context, HomePageController controller,
      {bool isManualEntry = false}) {
    if (result == PackageResult.success) {
      Navigator.of(context).pop();
      if (!isManualEntry) {
        _showScannerAndBottomSheet(context, controller);
      }
    } else if (result == PackageResult.isDuplicate) {
      SnackbarService.showCustomSnackbar(
        title: 'Duplicate Package',
        message: 'This package has already been received.',
        backgroundColor: Colors.red,
      );
    } else {
      ErrorHandler.handleError(result);
    }
  }

  void showTrackingNumberEntry(
      BuildContext context, HomePageController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (_) async {
          if (controller.isSaving.value) return;
          PackageResult result = await controller.processAndSavePackage(
              controller.trackingNumberController.text.toUpperCase());

          _handlePackageResult(result, context, controller,
              isManualEntry: true);
          if (result == PackageResult.success) {
            controller.trackingNumberController.clear();
          }
        },
        controller: controller.trackingNumberController,
      ),
    );
  }
}
