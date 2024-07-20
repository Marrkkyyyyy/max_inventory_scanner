import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/strings.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class ProblemTypeSection extends StatelessWidget {
  final RxBool isImageCaptured;
  final Rx<String?> selectedProblemType;
  final RxBool showOtherProblemField;
  final TextEditingController otherProblemController;
  final Function(String?) onProblemTypeChanged;
  final Function(String) onOtherProblemChanged;

  const ProblemTypeSection({
    super.key,
    required this.isImageCaptured,
    required this.selectedProblemType,
    required this.showOtherProblemField,
    required this.otherProblemController,
    required this.onProblemTypeChanged,
    required this.onOtherProblemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isImageCaptured.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedProblemType.value,
              decoration: InputDecoration(
                labelText: 'Problem Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColor.blue),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('No Problem Type Selected'),
                ),
                ...AppStrings.problemTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )),
              ],
              onChanged: onProblemTypeChanged,
              hint: const Text('Select problem type (optional)'),
            ),
            if (showOtherProblemField.value) ...[
              const SizedBox(height: 12),
              TextField(
                controller: otherProblemController,
                decoration: InputDecoration(
                  labelText: 'Specify',
                  hintText: 'Specify the problem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColor.blue),
                  ),
                ),
                onChanged: onOtherProblemChanged,
              ),
            ],
          ],
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
