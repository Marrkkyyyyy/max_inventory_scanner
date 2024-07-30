import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/measurement_controller.dart';

class MeasurementBottomSheet extends GetView<MeasurementController> {
  final VoidCallback onSaveAndExit;

  const MeasurementBottomSheet({
    super.key,
    required this.onSaveAndExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.straighten, size: 48, color: AppColor.blue),
          const SizedBox(height: 16),
          const Text(
            'Enter Package Measurements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildTextField(
              'Length', controller.lengthController, controller.lengthError),
          const SizedBox(height: 12),
          _buildTextField(
              'Weight', controller.weightController, controller.weightError),
          const SizedBox(height: 12),
          _buildTextField(
              'Height', controller.heightController, controller.heightError),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  onPressed: () => _onSave(onSaveAndExit),
                  text: 'Save & Exit',
                  icon: Icons.check_circle_outline,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildButton(
                  onPressed: () => controller.saveAndNext(context),
                  text: 'Save & Next',
                  icon: Icons.save_alt_rounded,
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Cancel',
            icon: Icons.cancel_outlined,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController textController, RxString errorText) {
    return Obx(() => TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText.value.isNotEmpty ? errorText.value : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: errorText.value.isEmpty ? AppColor.blue : Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: errorText.value.isEmpty ? AppColor.blue : Colors.red,
                  width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
        ));
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon,
          color: isPrimary ? AppColor.white : AppColor.blue, size: 24),
      label: Text(
        text,
        style: TextStyle(
          color: isPrimary ? AppColor.white : AppColor.blue,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColor.blue : AppColor.white,
        foregroundColor: isPrimary ? AppColor.white : AppColor.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : AppColor.blue,
            width: 1.5,
          ),
        ),
        elevation: isPrimary ? 3 : 0,
      ),
    );
  }

  void _onSave(VoidCallback saveAction) {
    if (controller.validateMeasurements()) {
      saveAction();
    }
  }
}
