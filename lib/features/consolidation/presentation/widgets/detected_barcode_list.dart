import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';

class DetectedBarcodesList extends StatelessWidget {
  final ConsolidationProcessController controller;
  final Function(BuildContext, int) onRemove;

  const DetectedBarcodesList({
    super.key,
    required this.controller,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.detectedBarcodes.isEmpty) {
          return _buildEmptyState();
        } else {
          return _buildBarcodeList(context);
        }
      }),
    );
  }

  Widget _buildEmptyState() {
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
  }

  Widget _buildBarcodeList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Packages",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: controller.detectedBarcodes.length,
              itemBuilder: (context, index) => _buildPackageItem(
                controller.detectedBarcodes[index],
                context,
                index,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(String itemName, BuildContext context, int index) {
    return Card(
      elevation: 2,
      color: Colors.white,
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
          onPressed: () => onRemove(context, index),
        ),
      ),
    );
  }
}
