import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/settings/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings',
              style: TextStyle(
                  color: AppColor.darkBlue, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColor.darkBlue),
        ),
        body: Obx(() => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildTextField(
                      title: 'Name',
                      controller: controller.nameController,
                      icon: Icons.person,
                      isValid: controller.isNameValid.value,
                    ),
                    const SizedBox(height: 24),
                    _buildDropdown(
                      title: 'Location',
                      value: controller.role.value,
                      items: controller.roles,
                      onChanged: controller.setRole,
                      icon: Icons.location_on,
                      isValid: controller.isRoleValid.value,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: controller.saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Settings',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildTextField({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required bool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColor.darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isValid ? Colors.transparent : Colors.red,
              width: 1.5,
            ),
          ),
          child: TextField(
            textCapitalization: TextCapitalization.words,
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColor.blue),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: const TextStyle(color: AppColor.darkBlue),
          ),
        ),
        if (!isValid)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'This field is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required bool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColor.darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isValid ? Colors.transparent : Colors.red,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: AppColor.blue),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.isEmpty ? null : value,
                    isExpanded: true,
                    hint: const Text('Choose location'),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    style:
                        const TextStyle(color: AppColor.darkBlue, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isValid)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Please select a location',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
