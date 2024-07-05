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
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => handlePopScope(context, false),
    ),
    title: const Text("Package Consolidation",
        style: TextStyle(color: Colors.white)),
    backgroundColor: AppColor.blue,
    elevation: 0,
  );
}

Widget buildBody(
    BuildContext context, ConsolidationProcessController controller) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMainPackageInfo(controller),
        const SizedBox(height: 16),
        _buildDetectedBarcodesList(controller),
        const SizedBox(height: 16),
        _buildScanOptions(context),
        const SizedBox(height: 16),
        _buildDoneConsolidateButton(context),
      ],
    ),
  );
}

Widget _buildMainPackageInfo(ConsolidationProcessController controller) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColor.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.blue.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.inventory_2_rounded, color: AppColor.blue, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Main Package",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColor.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.barcodeResult!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetectedBarcodesList(ConsolidationProcessController controller) {
  return Expanded(
    child: Obx(() {
      if (controller.detectedBarcodes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 48, color: AppColor.blue.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                "No packages added yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColor.darkBlue.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Scan or manually enter package\ntracking numbers to consolidate",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      } else {
        return ListView.builder(
          itemCount: controller.detectedBarcodes.length,
          itemBuilder: (context, index) => _buildPackageItem(
            controller.detectedBarcodes[index],
            context,
            index,
          ),
        );
      }
    }),
  );
}

Widget _buildPackageItem(String itemName, BuildContext context, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: const Icon(Icons.qr_code_rounded, color: AppColor.blue),
      title: Text(
        itemName,
        style: const TextStyle(fontSize: 16, color: AppColor.darkBlue),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        onPressed: () => _showRemoveConfirmationDialog(context, index),
      ),
    ),
  );
}

Widget _buildScanOptions(BuildContext context) {
  return Row(
    children: [
      Expanded(
          child: _buildOptionButton(
        context: context,
        icon: Icons.keyboard,
        label: "Manual Entry",
        onTap: () => _showTrackingNumberEntry(context),
      )),
      const SizedBox(width: 16),
      Expanded(
          child: _buildOptionButton(
        context: context,
        icon: Icons.qr_code_scanner_rounded,
        label: "Scan Package",
        onTap: () => _showScannerDialog(context),
      )),
    ],
  );
}

Widget _buildOptionButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 24),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: AppColor.blue,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColor.blue),
      ),
    ),
  );
}

Widget _buildDoneConsolidateButton(BuildContext context) {
  final controller = Get.find<ConsolidationProcessController>();
  return ElevatedButton.icon(
    onPressed: controller.consolidatePackages,
    icon: const Icon(Icons.check_circle_outline, size: 24),
    label: const Text("Complete Consolidation"),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void _showRemoveConfirmationDialog(BuildContext context, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) => CustomConfirmationDialog(
      message: "Are you sure you want to remove this package?",
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

void _showScannerDialog(BuildContext context) {
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

void _showTrackingNumberEntry(BuildContext context) {
  final controller = Get.find<ConsolidationProcessController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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

Future<void> handlePopScope(BuildContext context, bool didPop) async {
  if (didPop) return;
  final shouldPop = await _showExitConfirmationDialog(context);
  if (shouldPop) Navigator.of(context).pop();
}

Future<bool> _showExitConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => CustomConfirmationDialog(
          message:
              "Are you sure you want to exit? Any unsaved changes will be lost.",
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
          titleText: "Confirm Exit",
          cancelText: "Stay",
          confirmText: "Exit",
          confirmTextColor: Colors.red,
        ),
      ) ??
      false;
}
