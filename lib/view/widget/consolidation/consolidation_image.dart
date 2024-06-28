import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';

class ConsolidationImage extends StatelessWidget {
  const ConsolidationImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppImageASset.consolidation);
  }
}