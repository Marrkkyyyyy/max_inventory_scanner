import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class AddItemCard extends StatelessWidget {
  final VoidCallback onManualEntry;
  final VoidCallback onScan;

  const AddItemCard({
    super.key,
    required this.onManualEntry,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColor.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColor.blue),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline,
                color: AppColor.blue, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Add an item",
                style: TextStyle(
                  color: AppColor.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildButton("Manual", onManualEntry),
            const SizedBox(width: 8),
            _buildButton("Scan", onScan),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColor.white,
        backgroundColor: AppColor.blue,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
