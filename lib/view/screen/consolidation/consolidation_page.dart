import 'package:flutter/material.dart';

import '../../../core/constant/color.dart';
import '../../widget/consolidation/consolidation_description.dart';
import '../../widget/consolidation/consolidation_image.dart';
import '../../widget/consolidation/consolidation_option.dart';
import '../../widget/consolidation/start_consolidation_button.dart';

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
            const ConsolidationDescription(),
            const SizedBox(height: 8),
            const ConsolidationImage(),
            const SizedBox(height: 8),
            StartConsolidationButton(onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ConsolidationOption();
                  });
            }),
          ],
        ),
      ),
    );
  }
}
