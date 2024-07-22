import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/tracking_number_entry_modal.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/home/controller/home_controller.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

Widget buildConsolidationContent(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _consolidationHeader(),
        const SizedBox(height: 12),
        _consolidationDescription(),
        const SizedBox(height: 24),
        _consolidationImage(),
        const SizedBox(height: 32),
        _consolidationOptions(context),
      ],
    ),
  );
}

Widget _consolidationHeader() {
  return const Text(
    "Package Consolidation",
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColor.darkBlue,
    ),
  );
}

Widget _consolidationDescription() {
  return const Text(
    "Combine multiple packages into one shipment",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
      height: 1.5,
    ),
    textAlign: TextAlign.center,
  );
}

Widget _consolidationImage() {
  return Container(
    height: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        AppImageASset.consolidation,
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget _consolidationOptions(BuildContext context) {
  return Column(
    children: [
      _optionSection(
        context: context,
        title: 'Existing Box',
        icon: Icons.inventory_2,
        isNewBox: false,
      ),
      const SizedBox(height: 24),
      _optionSection(
        context: context,
        title: 'New Box',
        icon: Icons.add_box,
        isNewBox: true,
      ),
    ],
  );
}

Widget _optionSection({
  required BuildContext context,
  required String title,
  required IconData icon,
  required bool isNewBox,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColor.lightSky.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!, width: 1),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 28, color: AppColor.darkBlue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                context: context,
                title: 'Manual Entry',
                icon: Icons.edit,
                onPressed: () =>
                    _showManualEntryDialog(context, isNewBox: isNewBox),
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                context: context,
                title: 'Scan Barcode',
                icon: Icons.qr_code_scanner,
                onPressed: () =>
                    _showConsolidationScanner(context, isNewBox: isNewBox),
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _actionButton({
  required BuildContext context,
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
  required bool isPrimary,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 24),
    label: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? AppColor.blue : Colors.white,
      foregroundColor: isPrimary ? Colors.white : AppColor.blue,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColor.blue, width: 1),
      ),
      elevation: isPrimary ? 3 : 0,
    ),
  );
}

void _showConsolidationScanner(BuildContext context, {required bool isNewBox}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => CustomScanner(
      onBarcodeDetected: (barcode) {
        Navigator.of(context).pop();
        _navigateToConsolidation(context, barcode: barcode, isNewBox: isNewBox);
      },
    ),
  ));
}

void _showManualEntryDialog(BuildContext context, {required bool isNewBox}) {
  final controller = Get.find<HomeController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    builder: (BuildContext context) => TrackingNumberEntryModal(
      onAdd: (_) async {},
      controller: controller.manualTrackingNumberController,
    ),
  );
}

void _navigateToConsolidation(BuildContext context,
    {required String barcode, required bool isNewBox}) {
  final controller = Get.find<ConsolidationController>();
  Get.toNamed(AppRoute.CONSOLIDATION, arguments: {
    "barcodeResult": barcode,
    "location": controller.location,
    "isNewBox": isNewBox,
  });
}
