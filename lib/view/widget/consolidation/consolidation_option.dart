import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/view/widget/consolidation/scan_new_barcode_dialog.dart';

class ConsolidationOption extends StatelessWidget {
  const ConsolidationOption({super.key});

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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3282B8),
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
                  Icon(Icons.archive_rounded, size: 24, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Use Existing Package',
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
                side: const BorderSide(color: Color(0xFF3282B8)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (BuildContext contex) {
                      return const ScanNewBarcodeDialog();
                    });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_box, size: 24, color: Color(0xFF3282B8)),
                  SizedBox(width: 8),
                  Text(
                    'Use New Box',
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
