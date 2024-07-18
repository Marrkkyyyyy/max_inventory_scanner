import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';

class MeasurementsSection extends StatelessWidget {
  final ConsolidationProcessController controller;
  final VoidCallback onEdit;

  const MeasurementsSection(
      {super.key, required this.controller, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConsolidationProcessController>(
      builder: (controller) => Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Measurements",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColor.blue),
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildMeasurementInfo(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementInfo(ConsolidationProcessController controller) {
    final hasMeasurements = controller.lengthController.text.isNotEmpty ||
        controller.weightController.text.isNotEmpty ||
        controller.heightController.text.isNotEmpty;

    if (!hasMeasurements) {
      return const Text(
        "No measurements added",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMeasurementItem(
            Icons.straighten, "Length", controller.lengthController.text),
        _buildMeasurementItem(
            Icons.scale_outlined, "Weight", controller.weightController.text),
        _buildMeasurementItem(
            Icons.height, "Height", controller.heightController.text),
      ],
    );
  }

  Widget _buildMeasurementItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColor.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : "-",
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColor.darkBlue),
        ),
      ],
    );
  }
}
