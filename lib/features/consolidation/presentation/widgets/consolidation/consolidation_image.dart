
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';

class ConsolidationImage extends StatelessWidget {
  const ConsolidationImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          AppImageASset.consolidation,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}