import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';

class StartConsolidationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartConsolidationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
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
}
