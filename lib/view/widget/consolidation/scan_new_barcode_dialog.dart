import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/routes.dart';

import '../../../utils/custom_scanner.dart';

class ScanNewBarcodeDialog extends StatelessWidget {
  const ScanNewBarcodeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              "Please attach a new barcode label to the box",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.blue2,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_outlined,
                      size: 24, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Scan New Barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColor.blue2),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColor.blue2,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0,
                    ),
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
