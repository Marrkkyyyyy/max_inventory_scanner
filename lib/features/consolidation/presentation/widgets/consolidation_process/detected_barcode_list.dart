import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation_process/package_item.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation_process/add_item_card.dart';

class DetectedBarcodesList extends StatelessWidget {
  final ConsolidationProcessController controller;
  final Function(int) onTap;
  final Function(int) onRemove;
  final VoidCallback onManualEntry;
  final VoidCallback onScan;

  const DetectedBarcodesList({
    super.key,
    required this.controller,
    required this.onTap,
    required this.onRemove,
    required this.onManualEntry,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final itemCount = controller.barcodeController.detectedPackages.isEmpty
          ? 1
          : controller.barcodeController.detectedPackages.length + 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Packages (${controller.barcodeController.detectedPackages.length})",
              style: const TextStyle(
                color: AppColor.darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemCount,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                if (index ==
                    controller.barcodeController.detectedPackages.length) {
                  return AddItemCard(
                    onManualEntry: onManualEntry,
                    onScan: onScan,
                  );
                } else {
                  return PackageItem(
                    packageInfo:
                        controller.barcodeController.detectedPackages[index],
                    onTap: () => onTap(index),
                    onRemove: () => onRemove(index),
                  );
                }
              },
            ),
          ),
        ],
      );
    });
  }
}
