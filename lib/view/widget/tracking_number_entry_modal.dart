import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/utils/snackbar_service.dart';
import '../../core/constant/color.dart';

class TrackingNumberEntryModal extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController controller;

  const TrackingNumberEntryModal({
    super.key,
    required this.onAdd,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * .3,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Tracking Number',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Enter Tracking No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColor.blue2, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              controller.clear();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: AppColor.blue2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  color: AppColor.blue2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final barcode = controller.text.trim();
                              if (barcode.isNotEmpty) {
                                onAdd(barcode);
                              } else {
                                SnackbarService.showCustomSnackbar(
                                  title: 'Empty Barcode',
                                  message: 'Please enter a valid barcode.',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.blue2,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
