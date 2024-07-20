import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class PackageDetailsHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onRemove;
  final VoidCallback onReScan;

  const PackageDetailsHeader({
    super.key,
    required this.isEditing,
    this.onRemove,
    required this.onReScan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Package Details",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onRemove,
            tooltip: 'Remove',
          )
        else
          IconButton(
            icon:
                const Icon(Icons.qr_code_scanner_rounded, color: AppColor.blue),
            onPressed: onReScan,
            tooltip: 'Re-scan',
          ),
      ],
    );
  }
}
