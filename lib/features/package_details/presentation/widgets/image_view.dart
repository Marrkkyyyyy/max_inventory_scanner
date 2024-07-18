import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class ImageViewDialog extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRetake;

  const ImageViewDialog({
    super.key,
    required this.imageFile,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                height: Get.height * 0.4,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: onRetake,
                  icon: const Icon(Icons.camera_alt, color: AppColor.white),
                  label: const Text(
                    'Retake',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.blue,
                    foregroundColor: AppColor.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppColor.blue),
                  label: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.blue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColor.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
