import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';

class ConsosolidationBarcodeBottomSheet extends StatelessWidget {
  final String barcodeResult;
  final VoidCallback onReScan;
  final VoidCallback onSaveAndNext;

  const ConsosolidationBarcodeBottomSheet({
    super.key,
    required this.barcodeResult,
    required this.onReScan,
    required this.onSaveAndNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 22, right: 16, left: 16, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barcode / QR code Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review your Barcode/QR code details:',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.qr_code, barcodeResult),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: AppColor.blue2,
                          size: 24,
                        ),
                        label: const Text('Re-scan',
                            style: TextStyle(
                                color: AppColor.blue2,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                        onPressed: onReScan,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColor.blue2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          'Save & Next',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        onPressed: onSaveAndNext,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColor.blue2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'This package is already in receiving status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black54,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColor.blue2, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
