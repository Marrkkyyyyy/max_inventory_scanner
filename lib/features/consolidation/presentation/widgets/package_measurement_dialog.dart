import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class PackageMeasurementDialog extends StatelessWidget {
  final TextEditingController lengthController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final VoidCallback onSave;

  const PackageMeasurementDialog({
    super.key,
    required this.lengthController,
    required this.weightController,
    required this.heightController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Package Measurements",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildMeasurementField(
                lengthController, "Length", Icons.straighten),
            const SizedBox(height: 12),
            _buildMeasurementField(
                weightController, "Weight", Icons.scale_outlined),
            const SizedBox(height: 12),
            _buildMeasurementField(heightController, "Height", Icons.height),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Measurements"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColor.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.blue, width: 2),
        ),
      ),
    );
  }
}
