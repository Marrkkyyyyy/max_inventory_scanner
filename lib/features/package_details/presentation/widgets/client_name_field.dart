import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/controller/package_details_controller.dart';

class ClientNameFieldWidget extends GetView<PackageDetailsController> {
  const ClientNameFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Focus(
                  onFocusChange: (hasFocus) {
                    controller.isTextFieldFocused.value = hasFocus;
                  },
                  child: TextField(
                    controller: controller.clientNameController,
                    enabled: !(controller.hasProblem.value &&
                        controller.selectedProblemType.value == 'No Name'),
                    decoration: InputDecoration(
                      hintText: 'Enter client name',
                      labelText: 'Client Name',
                      labelStyle: const TextStyle(color: Colors.black45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: controller.isClientNameValid.value
                              ? AppColor.blue.withOpacity(0.3)
                              : AppColor.darkRed,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: controller.isClientNameValid.value
                              ? AppColor.blue
                              : AppColor.darkRed,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: controller.isClientNameValid.value
                              ? AppColor.blue
                              : AppColor.darkRed,
                        ),
                      ),
                      prefixIcon: Icon(Icons.person,
                          color: controller.isClientNameValid.value
                              ? AppColor.blue
                              : AppColor.darkRed),
                      errorText: controller.isClientNameValid.value
                          ? null
                          : controller.clientNameError.value,
                      errorStyle: const TextStyle(
                        color: AppColor.darkRed,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (_) => controller.validateClientName(),
                  ),
                ),
                if (controller.clientNameController.text.isNotEmpty &&
                    controller.showSuggestions.value &&
                    controller.isTextFieldFocused.value)
                  controller.clientSuggestions.isEmpty
                      ? _buildNoSuggestionsFound()
                      : _buildSuggestions(),
              ],
            )),
      ],
    );
  }

  Widget _buildNoSuggestionsFound() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'No name found',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 225),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.clientSuggestions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              controller.selectClientName(controller.clientSuggestions[index]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.clientSuggestions[index],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
