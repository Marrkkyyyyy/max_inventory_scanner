import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/tracking_number_entry_modal.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/action_button.dart';
import 'package:max_inventory_scanner/routes/routes.dart';

class OptionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isNewBox;

  const OptionSection({
    super.key,
    required this.title,
    required this.icon,
    required this.isNewBox,
  });

  @override
  Widget build(BuildContext context) {
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
                child: ActionButton(
                  title: 'Manual Entry',
                  icon: Icons.edit,
                  onPressed: () =>
                      showManualEntryDialog(context, isNewBox: isNewBox),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  title: 'Scan Barcode',
                  icon: Icons.qr_code_scanner,
                  onPressed: () =>
                      showConsolidationScanner(context, isNewBox: isNewBox),
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showConsolidationScanner(BuildContext context,
      {required bool isNewBox}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          navigateToConsolidation(context,
              barcode: barcode, isNewBox: isNewBox);
        },
      ),
    ));
  }

  void showManualEntryDialog(BuildContext context, {required bool isNewBox}) {
    final controller = Get.find<ConsolidationController>();
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

  void navigateToConsolidation(BuildContext context,
      {required String barcode, required bool isNewBox}) {
    final controller = Get.find<ConsolidationController>();
    Get.toNamed(AppRoute.CONSOLIDATION_PROCCESS, arguments: {
      "barcodeResult": barcode,
      "location": controller.location.value,
      "isNewBox": isNewBox,
    });
  }
}
