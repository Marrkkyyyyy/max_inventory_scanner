import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/view/widget/consolidation/consolidation_widgets.dart';
import '../../../core/constant/color.dart';

class ConsolidationPage extends StatelessWidget {
  const ConsolidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        backgroundColor: AppColor.blue3,
        centerTitle: true,
        title: const Text("Consolidation"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            consolidationDescription(),
            const SizedBox(height: 8),
            consolidationImage(),
            const SizedBox(height: 8),
            startConsolidationButton(context),
          ],
        ),
      ),
    );
  }
}
