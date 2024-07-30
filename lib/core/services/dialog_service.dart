import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class DialogService {
  Future<bool?> showPhotoConfirmationDialog() async {
    return _showCustomDialog(
      icon: Icons.camera_alt,
      title: 'Take a Photo',
      content:
          'Photo recommended for unknown carriers. Would you like to take a photo?',
      confirmText: 'Take Photo',
      cancelText: 'Skip',
      barrierDismissible: false,
    );
  }

  Future<bool?> showPhotoRequiredDialog(String message) async {
    return _showCustomDialog(
      icon: Icons.camera_alt,
      title: 'Photo is Required',
      content:
          message,
      confirmText: 'Take Photo',
      cancelText: 'Close',
      barrierDismissible: false,
    );
  }

  Future<bool?> showConsolidationConfirmationDialog(
      bool isSinglePackage) async {
    String content = isSinglePackage
        ? "Are you sure you want to consolidate this package to itself? This will update its measurements."
        : "Are you sure you want to consolidate these packages?";

    return _showCustomDialog(
      icon: Icons.inventory_2,
      title: 'Confirm Consolidation',
      content: content,
      confirmText: 'Consolidate',
      cancelText: 'Cancel',
    );
  }

  Future<bool?> _showCustomDialog({
    required IconData icon,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    bool barrierDismissible = true,
  }) async {
    bool? result = await Get.dialog<bool>(
      PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Get.back(result: null);
        },
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: AppColor.blue),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.blue,
                          side: const BorderSide(color: AppColor.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );

    FocusManager.instance.primaryFocus?.unfocus();

    return result;
  }
}
