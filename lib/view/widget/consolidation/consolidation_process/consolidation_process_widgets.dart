import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/controller/consolidation/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/utils/custom_confirmation_dialog.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';
import '../../../../core/constant/color.dart';
import '../../tracking_number_entry_modal.dart';

PreferredSizeWidget buildAppBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    automaticallyImplyLeading: false,
    elevation: 2,
    backgroundColor: AppColor.blue3,
    title: const Text("Discard"),
  );
}

Widget buildBody(
    BuildContext context, ConsolidationProcessController controller) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    child: Column(
      children: [
        buildBarcodeResultContainer(controller),
        const Divider(height: 24),
        buildDetectedBarcodesList(controller),
        const SizedBox(height: 16),
        buildScanOptions(context),
        const SizedBox(height: 12),
        buildDoneConsolidateButton(context),
      ],
    ),
  );
}

Widget buildBarcodeResultContainer(ConsolidationProcessController controller) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColor.blue1,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.inventory_2_rounded, color: AppColor.blue2, size: 32),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            controller.barcodeResult!,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black54),
          ),
        )
      ],
    ),
  );
}

Widget buildDetectedBarcodesList(ConsolidationProcessController controller) {
  return Expanded(
    child: Obx(() => ListView.builder(
          itemCount: controller.detectedBarcodes.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: buildPackageItem(
                controller.detectedBarcodes[index], context, index),
          ),
        )),
  );
}

Widget buildPackageItem(String itemName, BuildContext context, int index) {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.qr_code_rounded, color: AppColor.blue2, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              itemName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => showRemoveConfirmationDialog(context, index),
          )
        ],
      ),
    ),
  );
}

void showRemoveConfirmationDialog(BuildContext context, int index) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomConfirmationDialog(
      message: "Are you sure you want to remove this item?",
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () {
        Get.find<ConsolidationProcessController>().removeDetectedBarcode(index);
        Navigator.of(context).pop();
      },
      titleText: "Confirm Removal",
      cancelText: "Cancel",
      confirmText: "Remove",
      confirmTextColor: Colors.red,
    ),
  );
}

Widget buildScanOptions(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => showTrackingNumberEntry(context),
          child: _buildOptionContainer(
            icon: Icons.keyboard,
            label: "MANUAL",
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: () => showScannerDialog(context),
          child: _buildOptionContainer(
            icon: Icons.qr_code_scanner_rounded,
            label: "SCAN",
          ),
        ),
      ),
    ],
  );
}

Widget _buildOptionContainer({required IconData icon, required String label}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: AppColor.blue2,
        width: 2.0,
      ),
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Icon(
          icon,
          size: 36,
          color: AppColor.blue3,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: AppColor.blue3),
        ),
      ],
    ),
  );
}

Widget buildDoneConsolidateButton(BuildContext context) {
  final controller = Get.find<ConsolidationProcessController>();
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.save, color: Colors.white, size: 28),
      label: const Text(
        "DONE CONSOLIDATE",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onPressed: () => controller.consolidatePackages(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.blue2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

void showScannerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => CustomScanner(
      onBarcodeDetected: (barcode) {
        Navigator.of(context).pop();
        Get.find<ConsolidationProcessController>().addDetectedBarcode(barcode);
      },
    ),
  );
}

void showTrackingNumberEntry(BuildContext context) {
  final controller = Get.find<ConsolidationProcessController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    builder: (BuildContext context) => TrackingNumberEntryModal(
      onAdd: (val) {
        if (controller.addDetectedBarcode(val)) {
          Navigator.of(context).pop();
          controller.trackingNumberController.clear();
        }
      },
      controller: controller.trackingNumberController,
    ),
  );
}
