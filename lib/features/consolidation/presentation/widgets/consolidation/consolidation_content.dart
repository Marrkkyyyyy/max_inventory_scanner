
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/consolidation_description.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/consolidation_header.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/consolidation_image.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/consolidation_options.dart';

class ConsolidationContent extends StatelessWidget {
  const ConsolidationContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:  [
        ConsolidationHeader(),
        SizedBox(height: 12),
        ConsolidationDescription(),
        SizedBox(height: 24),
        ConsolidationImage(),
        SizedBox(height: 32),
        ConsolidationOptions(),
      ],
    );
  }
}