import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/controller/consolidation/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/utils/custom_confirmation_dialog.dart';
import '../../widget/consolidation/consolidation_process/consolidation_process_widgets.dart';

class ConsolidationProcess extends StatelessWidget {
  const ConsolidationProcess({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsolidationProcessController());
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _handlePopScope(context, didPop),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(context, controller),
      ),
    );
  }

  Future<void> _handlePopScope(BuildContext context, bool didPop) async {
    if (didPop) return;
    final shouldPop = await _showExitConfirmationDialog(context);
    if (shouldPop) Navigator.of(context).pop();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => CustomConfirmationDialog(
            message:
                "Are you sure you want to exit? Any unsaved changes will be lost.",
            onCancel: () => Navigator.of(context).pop(false),
            onConfirm: () => Navigator.of(context).pop(true),
            titleText: "Confirm Exit",
            cancelText: "Cancel",
            confirmText: "Exit",
            confirmTextColor: Colors.red,
          ),
        ) ??
        false;
  }
}
