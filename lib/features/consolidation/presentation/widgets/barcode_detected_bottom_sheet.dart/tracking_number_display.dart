
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class TrackingNumberDisplay extends StatelessWidget {
  final String trackingNumber;

  const TrackingNumberDisplay({Key? key, required this.trackingNumber}) : super(key: key);

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
      child: Row(
        children: [
          const Icon(Icons.qr_code, color: AppColor.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tracking Number",
                  style: TextStyle(
                    color: AppColor.darkBlue.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trackingNumber,
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
      ),
    );
  }
}