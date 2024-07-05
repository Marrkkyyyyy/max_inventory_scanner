import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';
import 'package:max_inventory_scanner/routes.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';

Widget buildConsolidationContent(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Package Consolidation",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkBlue,
          ),
        ),
        const SizedBox(height: 16),
        _consolidationDescription(),
        const SizedBox(height: 24),
        _consolidationImage(),
        const SizedBox(height: 32),
        _startConsolidationButton(context),
      ],
    ),
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

Widget _consolidationDescription() {
  return const Text(
    "Combine multiple packages\ninto one shipment",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
      height: 1.5,
    ),
    textAlign: TextAlign.center,
  );
}

Widget _startConsolidationButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => _showConsolidationScanner(context),
      icon: const Icon(Icons.qr_code_scanner, size: 24),
      label: const Text(
        'Start Consolidation',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    ),
  );
}

void _showConsolidationScanner(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          Get.toNamed(AppRoute.consolidationProcess, arguments: {
            "barcodeResult": barcode,
          });
        },
      );
    },
  );
}
