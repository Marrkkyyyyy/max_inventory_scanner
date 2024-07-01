import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';
import 'package:max_inventory_scanner/routes.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';

Widget consolidationImage() {
  return Image.asset(AppImageASset.consolidation);
}

Widget consolidationDescription() {
  return const Text(
    "Combine multiple packages into one",
    style: TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black54),
  );
}

Widget startConsolidationButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
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
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.blue2,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      elevation: 2,
    ),
    child: const Text(
      'Start Consolidation',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
