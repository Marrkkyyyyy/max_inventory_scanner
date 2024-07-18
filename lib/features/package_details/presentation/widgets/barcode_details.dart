import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class BarcodeDetailsWidget extends StatelessWidget {
  final String logistic;
  final String displayTrackingNumber;

  const BarcodeDetailsWidget({
    super.key,
    required this.logistic,
    required this.displayTrackingNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blue.withOpacity(.8)),
        boxShadow: [
          BoxShadow(
            color: AppColor.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              'Tracking Number', displayTrackingNumber, Icons.qr_code),
          const SizedBox(height: 16),
          _buildDetailRow('Carrier', logistic, Icons.local_shipping),
        ],
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
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
