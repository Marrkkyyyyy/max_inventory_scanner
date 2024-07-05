import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/functions/carrier_and_tracking_number.dart';

class BarcodeBottomSheet extends StatelessWidget {
  final String barcodeResult;
  final VoidCallback onReScan;
  final Function() onSaveAndNext;
  final Function() onSave;

  const BarcodeBottomSheet({
    super.key,
    required this.barcodeResult,
    required this.onReScan,
    required this.onSaveAndNext,
    required this.onSave,
  });

  Future<String> getLogisticResult() async {
    return await identifyCourier(barcodeResult) ?? 'Unknown';
  }

  Future<String> getDisplayTrackingNumber(String logistic) async {
    if (logistic == 'USPS') {
      return cleanBarcode(barcodeResult);
    }
    return barcodeResult;
  }

  Future<String> getInternalTrackingNumber(
      String logistic, String displayedNumber) async {
    if (logistic == 'FedEx' && displayedNumber.length >= 12) {
      return displayedNumber.substring(displayedNumber.length - 12);
    }
    return displayedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBarcodeDetails(),
                const SizedBox(height: 32),
                _buildButtons(),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColor.darkBlue),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Package Details',
          style: TextStyle(
            color: AppColor.darkBlue,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Review the scanned package information:',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBarcodeDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blue.withOpacity(0.1)),
      ),
      child: FutureBuilder<String>(
        future: getLogisticResult(),
        builder: (context, logisticSnapshot) {
          if (logisticSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColor.blue));
          }
          return Column(
            children: [
              FutureBuilder<String>(
                future: getDisplayTrackingNumber(
                    logisticSnapshot.data ?? 'Unknown'),
                builder: (context, trackingSnapshot) {
                  if (trackingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppColor.blue));
                  }
                  return _buildDetailRow('Tracking Number',
                      trackingSnapshot.data ?? 'Unknown', Icons.qr_code);
                },
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                  'Carrier',
                  logisticSnapshot.data ?? 'Unknown Carrier',
                  Icons.local_shipping),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColor.blue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColor.darkBlue.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColor.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildButton(onReScan, 'Re-scan', Icons.qr_code_scanner,
                    isPrimary: false)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildButton(
                    onSaveAndNext, 'Save & Next', Icons.arrow_forward,
                    isPrimary: false)),
          ],
        ),
        const SizedBox(height: 16),
        _buildButton(onSave, 'Save Package', Icons.save, isPrimary: true),
      ],
    );
  }

  Widget _buildButton(VoidCallback onPressed, String text, IconData icon,
      {required bool isPrimary}) {
    return SizedBox(
      width: isPrimary ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon,
            color: isPrimary ? Colors.white : AppColor.blue, size: 24),
        label: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : AppColor.blue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColor.blue : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColor.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? Colors.transparent : AppColor.blue,
              width: 1.5,
            ),
          ),
          elevation: isPrimary ? 3 : 0,
        ),
      ),
    );
  }
}
