import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/color.dart';

class TrackingNumberEntryModal extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController controller;

  TrackingNumberEntryModal({
    super.key,
    required this.onAdd,
    required this.controller,
  });

  final RxBool showError = false.obs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tracking Number',
                      style: TextStyle(
                        color: AppColor.darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter the tracking number of the package you want to add to the inventory.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      title: 'Tracking Number',
                      controller: controller,
                      icon: CupertinoIcons.barcode,
                      showError: showError.value,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        final barcode = controller.text.trim();
                        if (barcode.isNotEmpty) {
                          showError.value = false;
                          onAdd(barcode);
                        } else {
                          showError.value = true;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Package',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.blue),
                        backgroundColor: AppColor.white,
                        foregroundColor: AppColor.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    required bool showError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColor.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showError ? Colors.red : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColor.blue),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Enter tracking number',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: const TextStyle(color: AppColor.darkBlue),
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Please enter a valid tracking number',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
