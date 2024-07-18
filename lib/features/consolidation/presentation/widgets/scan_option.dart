import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class ScanOptions extends StatelessWidget {
  final VoidCallback onManualEntry;
  final VoidCallback onScan;

  const ScanOptions({
    super.key,
    required this.onManualEntry,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(
            context: context,
            icon: Icons.keyboard,
            label: "Manual Entry",
            onTap: onManualEntry,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOptionButton(
            context: context,
            icon: Icons.qr_code_scanner_rounded,
            label: "Scan Package",
            onTap: onScan,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColor.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColor.blue),
        ),
      ),
    );
  }
}
