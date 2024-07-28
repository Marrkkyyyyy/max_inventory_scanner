import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/client_controller.dart';

class ConsolidationClientNameFieldWidget extends GetView<ClientController> {
  const ConsolidationClientNameFieldWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Focus(
                    onFocusChange: (hasFocus) {
                      controller.isTextFieldFocused.value = hasFocus;
                      if (!hasFocus) {
                        controller.validateClientName();
                      }
                    },
                    child: TextField(
                      controller: controller.clientNameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Enter client name',
                        labelText: 'Client Name',
                        labelStyle: const TextStyle(color: Colors.black45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: controller.isClientNameValid.value
                                ? AppColor.blue
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
                      onChanged: (_) => controller.onClientNameChanged(),
                      onSubmitted: (_) {
                        controller.isTextFieldFocused.value = false;
                        controller.validateClientName();
                      },
                    ),
                  ),
                  if (controller.isWarningVisible.value)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.warn2.withOpacity(0.1),
                        border: Border.all(color: AppColor.warn2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: AppColor.warn2,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.nameNotInListWarning.value,
                              style: const TextStyle(
                                color: AppColor.warn2,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (controller.showSuggestions.value &&
                      !controller.isWarningVisible.value)
                    _buildSuggestions(),
                ],
              )),
        ],
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
