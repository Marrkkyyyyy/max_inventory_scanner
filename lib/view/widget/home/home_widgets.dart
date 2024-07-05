import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/class/error_handler.dart';
import 'package:max_inventory_scanner/core/class/service_result.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';
import 'package:max_inventory_scanner/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/view/widget/home/damaged/image_bottom_sheet.dart';
import 'package:max_inventory_scanner/view/widget/home/scan/modal_barcode_result.dart';
import 'package:max_inventory_scanner/view/widget/tracking_number_entry_modal.dart';

Widget customHeader(String name, String location) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1, 3),
            blurRadius: 3.0,
            spreadRadius: 0,
          ),
        ],
        color: AppColor.lightSky,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.person_circle_fill,
          size: 70,
          color: AppColor.darkBlue,
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 18,
                  color: AppColor.darkBlue,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.red,
                )
              ],
            )
          ],
        ))
      ],
    ),
  );
}

Widget imageDisplay() {
  return Material(
    elevation: 2,
    borderRadius: BorderRadius.circular(8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(AppImageASset.mobileScan),
    ),
  );
}

void showScannerAndBottomSheet(
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
    isDismissible: false,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return BarcodeBottomSheet(
        barcodeResult: barcode,
        onReScan: () {
          Navigator.of(context).pop();
          showScannerAndBottomSheet(context, controller);
        },
        onSaveAndNext: () async {
          if (controller.isSaving.value) return;

          PackageResult result =
              await controller.processAndSavePackage(barcode);
          _handlePackageResult(result, context, controller);
        },
        onSave: () async {
          if (controller.isSaving.value) return;

          PackageResult result =
              await controller.processAndSavePackage(barcode);
          _handlePackageResult(result, context, controller, isSave: true);
        },
      );
    },
  );
}

void _handlePackageResult(
    PackageResult result, BuildContext context, HomePageController controller,
    {bool isManualEntry = false, bool isSave = false}) {
  if (result == PackageResult.success) {
    Navigator.of(context).pop();
    if (!isManualEntry && !isSave) {
      showScannerAndBottomSheet(context, controller);
    }
  } else if (result == PackageResult.isDuplicate) {
    SnackbarService.showCustomSnackbar(
      title: 'Duplicate Package',
      message: 'This package has already been scanned.',
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

        _handlePackageResult(result, context, controller, isManualEntry: true);
        if (result == PackageResult.success) {
          controller.trackingNumberController.clear();
        }
      },
      controller: controller.trackingNumberController,
    ),
  );
}

void takePictureAndShowBottomSheet(
    BuildContext context, HomePageController controller) async {
  await controller.takePicture();
  if (controller.imagePath.isNotEmpty) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ImageBottomSheet(controller: controller);
      },
    );
  }
}
