import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/widgets/custom_confirmation_dialog.dart';
import 'package:max_inventory_scanner/core/widgets/custom_scanner.dart';
import 'package:max_inventory_scanner/core/widgets/tracking_number_entry_modal.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/detected_barcode_list.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/main_package_info.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/measurement_section.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/package_measurement_dialog.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/scan_option.dart';

class ConsolidationProcess extends GetView<ConsolidationProcessController> {
  const ConsolidationProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _handlePopScope(context, didPop),
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: _buildAppBar(context),
        body: _buildBody(context, controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _handlePopScope(context, false),
      ),
      title: const Text("Package Consolidation",
          style: TextStyle(color: Colors.white)),
      backgroundColor: AppColor.blue,
      elevation: 0,
    );
  }

  Widget _buildBody(
      BuildContext context, ConsolidationProcessController controller) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height -
            AppBar().preferredSize.height -
            MediaQuery.of(context).padding.top,
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MainPackageInfo(controller: controller),
              const SizedBox(height: 4),
              MeasurementsSection(
                  controller: controller,
                  onEdit: () => _showMeasurementDialog(controller)),
              const SizedBox(height: 12),
              DetectedBarcodesList(
                  controller: controller,
                  onRemove: _showRemoveConfirmationDialog),
              const SizedBox(height: 16),
              ScanOptions(
                onManualEntry: () => _showTrackingNumberEntry(context),
                onScan: () => _showScannerDialog(context),
              ),
              const SizedBox(height: 16),
              _buildDoneConsolidateButton(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneConsolidateButton(
      BuildContext context, ConsolidationProcessController controller) {
    return Obx(() => ElevatedButton.icon(
          onPressed: controller.isConsolidating.value
              ? null
              : controller.consolidatePackages,
          icon: const Icon(Icons.check_circle_outline, size: 24),
          label: const Text("Complete Consolidation"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ));
  }

  void _showRemoveConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomConfirmationDialog(
        message: "Are you sure you want to remove this package?",
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          controller.removeDetectedBarcode(index);
          Navigator.of(context).pop();
        },
        titleText: "Confirm Removal",
        cancelText: "Cancel",
        confirmText: "Remove",
        confirmTextColor: Colors.red,
      ),
    );
  }

  void _showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          controller.addDetectedBarcode(barcode);
        },
      ),
    );
  }

  void _showTrackingNumberEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => TrackingNumberEntryModal(
        onAdd: (val) {
          if (controller.addDetectedBarcode(val)) {
            Navigator.of(context).pop();
            controller.trackingNumberController.clear();
          }
        },
        controller: controller.trackingNumberController,
      ),
    );
  }

  void _showMeasurementDialog(ConsolidationProcessController controller) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) => PackageMeasurementDialog(
        lengthController: controller.lengthController,
        weightController: controller.weightController,
        heightController: controller.heightController,
        onSave: () {
          controller.update();
          Navigator.of(context).pop();
        },
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
            cancelText: "Stay",
            confirmText: "Exit",
            confirmTextColor: Colors.red,
          ),
        ) ??
        false;
  }
}
