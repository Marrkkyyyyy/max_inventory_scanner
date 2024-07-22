import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/strings.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/theme/text_styles.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation/consolidation_content.dart';
import 'package:max_inventory_scanner/features/home/presentation/widgets/custom_header.dart';

class ConsolidationPage extends GetView<ConsolidationController> {
  const ConsolidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: TextStyles.appBarTextStyle(
            textColor: AppColor.darkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => customHeader(
                  controller.name.value, controller.location.value)),
              const SizedBox(height: 20),
              const ConsolidationContent(),
            ],
          ),
        ),
      ),
    );
  }
}
