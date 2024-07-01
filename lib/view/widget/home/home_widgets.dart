import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:max_inventory_scanner/core/class/error_handler.dart';
import 'package:max_inventory_scanner/core/class/service_result.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';
import 'package:max_inventory_scanner/utils/snackbar_service.dart';
import 'package:max_inventory_scanner/view/widget/home/damaged/image_bottom_sheet.dart';
import 'package:max_inventory_scanner/view/widget/home/scan/modal_barcode_result.dart';
import 'package:max_inventory_scanner/view/widget/tracking_number_entry_modal.dart';

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

Widget dropdownSelector(HomePageController controller) {
  return Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
    child: Container(
      padding: const EdgeInsets.only(left: 10, right: 15, bottom: 5, top: 5),
      width: Get.width,
      child: Obx(() => DropdownButtonFormField<String>(
            style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: "Manrope",
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please select address';
              }
              return null;
            },
            onChanged: (val) {
              if (val != null) {
                controller.setSelectedItem(val);
              }
            },
            value: controller.selectedLocation.value,
            items: controller.dropdownItems.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          )),
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
