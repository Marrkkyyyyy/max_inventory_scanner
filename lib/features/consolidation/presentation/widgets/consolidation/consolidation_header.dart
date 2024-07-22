
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class ConsolidationHeader extends StatelessWidget {
  const ConsolidationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Package Consolidation",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColor.darkBlue,
      ),
    );
  }
}