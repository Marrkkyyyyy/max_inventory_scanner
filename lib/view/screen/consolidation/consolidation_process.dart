import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/consolidation/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/utils/custom_confirmation_dialog.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';
import 'package:max_inventory_scanner/view/widget/consolidation/consolidation_process/consolidation_process_widgets.dart';
import 'package:max_inventory_scanner/view/widget/tracking_number_entry_modal.dart';

class ConsolidationProcess extends StatelessWidget {
  const ConsolidationProcess({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsolidationProcessController());
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => handlePopScope(context, didPop),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(context, controller),
      ),
    );
  }
}
