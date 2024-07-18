import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/strings.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/controller/package_details_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/image_view.dart';
class ProblemSection extends GetView<PackageDetailsController> {
  const ProblemSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: controller.hasProblem.value,
                  onChanged: (value) {
                    controller.toggleProblem(value);
                    FocusScope.of(context).unfocus();
                  },
                  activeColor: AppColor.blue,
                ),
                const Text('Damaged Package',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    )),
                const Spacer(),
                TextButton(
                  onPressed: controller.isImageCaptured.value
                      ? _showImageViewDialog
                      : () {
                          FocusScope.of(context).unfocus();
                          controller.takePhoto();
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: controller.isImageCaptured.value
                        ? AppColor.teal
                        : AppColor.blue,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    controller.isImageCaptured.value
                        ? "View Photo"
                        : "Take a Photo",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (controller.hasProblem.value) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: controller.selectedProblemType.value,
                decoration: InputDecoration(
                  labelText: 'Problem Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: controller.isProblemTypeValid.value
                          ? AppColor.blue
                          : AppColor.darkRed,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: controller.isProblemTypeValid.value
                          ? AppColor.blue
                          : AppColor.darkRed,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: controller.isProblemTypeValid.value
                          ? AppColor.blue
                          : AppColor.darkRed,
                      width: 2,
                    ),
                  ),
                  errorText: controller.isProblemTypeValid.value
                      ? null
                      : 'Please select a problem type',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: AppStrings.problemTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  controller.selectProblemType(value);
                  FocusScope.of(context).unfocus();
                },
                hint: const Text('Select problem type'),
              ),
              if (controller.showOtherProblemField.value) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: controller.otherProblemController,
                  decoration: InputDecoration(
                    labelText: 'Specify',
                    hintText: 'Specify the problem',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: controller.isOtherProblemValid.value
                            ? AppColor.blue
                            : AppColor.darkRed,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: controller.isOtherProblemValid.value
                            ? AppColor.blue
                            : AppColor.darkRed,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: controller.isOtherProblemValid.value
                            ? AppColor.blue
                            : AppColor.darkRed,
                        width: 2,
                      ),
                    ),
                    errorText: controller.isOtherProblemValid.value
                        ? null
                        : 'Please specify the problem',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ],
          ],
        ));
  }
  void _showImageViewDialog() {
    Get.dialog(
      ImageViewDialog(
        imageFile: controller.capturedImage.value!,
        onRetake: () {
          Get.back();
          controller.takePhoto();
        },
      ),
      barrierDismissible: false,
    );
  }
}