import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';

class MainPackageInfo extends StatelessWidget {
  final ConsolidationProcessController controller;

  const MainPackageInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_rounded,
                color: AppColor.blue, size: 32),
            const SizedBox(width: 16),
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
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
