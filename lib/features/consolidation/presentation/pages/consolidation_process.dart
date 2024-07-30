import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/widgets/custom_confirmation_dialog.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation_process/client_name_field.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation_process/detected_barcode_list.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation_process/main_package_info.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/consolidation_process/warning_message.dart';

class ConsolidationProcess extends GetView<ConsolidationProcessController> {
  const ConsolidationProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _handlePopScope(context, didPop),
      child: GestureDetector(
        onTap: () => _unfocusKeyboard(context),
        child: Scaffold(
          backgroundColor: AppColor.white,
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          bottomNavigationBar: _buildCompleteConsolidationButton(context),
        ),
      ),
    );
  }

  // AppBar
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

  // Body
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWarningMessage(),
          buildPhotoButton(context),
          _buildClientNameField(),
          const MainPackageInfo(),
          const SizedBox(height: 12),
          _buildDetectedBarcodesList(context),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Obx(() => WarningMessage(
          isNewBox: controller.isNewBox.value,
          packageExists: controller.packageExists.value,
        ));
  }

  Widget buildPhotoButton(BuildContext context) {
    return Obx(() {
      if (!controller.isNewBox.value && !controller.packageExists.value) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton.icon(
              onPressed: controller.isImageCaptured.value
                  ? () => controller.showImageViewDialog(context,
                      controller.capturedImage.value!, controller.takePhoto)
                  : controller.takePhoto,
              icon: Icon(
                controller.isImageCaptured.value
                    ? Icons.photo
                    : Icons.camera_alt,
                color: AppColor.white,
              ),
              label: Text(
                controller.isImageCaptured.value
                    ? "View Photo"
                    : "Take a Photo",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: controller.isImageCaptured.value
                      ? AppColor.teal
                      : AppColor.blue,
                  side: controller.isImageCaptured.value
                      ? BorderSide(color: AppColor.teal)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Widget _buildClientNameField() {
    return Obx(() => controller.isNewBox.value
        ? const ConsolidationClientNameFieldWidget()
        : const SizedBox());
  }

  Widget _buildDetectedBarcodesList(BuildContext context) {
    return Expanded(
      child: DetectedBarcodesList(
        controller: controller,
        onTap: (index) => controller.barcodeController
            .showBarcodeDetectedBottomSheet(context,
                controller.barcodeController.detectedPackages[index], index),
        onRemove: controller.barcodeController.removeDetectedPackage,
        onManualEntry: () => controller.trackingNumberController
            .showTrackingNumberEntry(context),
        onScan: () => controller.barcodeController.showScannerDialog(context),
      ),
    );
  }

  // Bottom Button
  Widget _buildCompleteConsolidationButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
      child: ElevatedButton.icon(
        onPressed: () => controller.measurementController
            .showMeasurementBottomSheet(context),
        icon: const Icon(Icons.check_circle_outline, size: 24),
        label: const Text("Complete Consolidation"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Helper Methods
  void _unfocusKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus!.unfocus();
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
