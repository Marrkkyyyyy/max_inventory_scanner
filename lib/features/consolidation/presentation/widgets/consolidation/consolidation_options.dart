import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/option_section.dart';

class ConsolidationOptions extends StatelessWidget {
  const ConsolidationOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        OptionSection(
          title: 'Existing Box',
          icon: Icons.inventory_2,
          isNewBox: false,
        ),
        SizedBox(height: 24),
        OptionSection(
          title: 'New Box',
          icon: Icons.add_box,
          isNewBox: true,
        ),
      ],
    );
  }
}
