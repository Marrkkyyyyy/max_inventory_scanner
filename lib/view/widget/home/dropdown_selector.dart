import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controller/home/home_page_controller.dart';

class DropdownSelector extends StatelessWidget {
  final HomePageController controller;

  const DropdownSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 15, bottom: 5, top: 5),
        width: Get.width,
        child: Obx(() => DropdownButtonFormField<String>(
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please select address';
                }
                return null;
              },
              onChanged: (val) {
                if (val != null) {
                  controller.setSelectedItem(val);
                }
              },
              value: controller.selectedItem.value,
              items: controller.dropdownItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            )),
      ),
    );
  }
}
