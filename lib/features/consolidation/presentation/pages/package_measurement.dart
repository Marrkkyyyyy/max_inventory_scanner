import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';

class MeasurementBottomSheet extends StatelessWidget {
  final ConsolidationProcessController controller;
  final VoidCallback onSaveAndNext;
  final VoidCallback onSaveAndExit;

  const MeasurementBottomSheet({
    super.key,
    required this.controller,
    required this.onSaveAndNext,
    required this.onSaveAndExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
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
          const SizedBox(height: 12),
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
          _buildTextField('Length', controller.lengthController,
              autofocus: true),
          const SizedBox(height: 12),
          _buildTextField('Weight', controller.weightController),
          const SizedBox(height: 12),
          _buildTextField('Height', controller.heightController),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  onPressed: () {},
                  text: 'Save & Exit',
                  icon: Icons.check_circle_outline,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildButton(
                  onPressed: () {},
                  text: 'Save & Next',
                  icon: Icons.save_alt_rounded,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildTextField(String label, TextEditingController textController,
      {bool autofocus = false}) {
    return TextField(
      controller: textController,
      autofocus: autofocus,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.blue, width: 1.7),
          borderRadius: BorderRadius.circular(8),
        ),
        labelText: label,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: TextInputType.number,
    );
  }
}
