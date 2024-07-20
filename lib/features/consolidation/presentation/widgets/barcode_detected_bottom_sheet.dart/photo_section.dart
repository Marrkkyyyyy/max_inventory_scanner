import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class PhotoSection extends StatelessWidget {
  final RxBool isImageCaptured;
  final Rx<File?> capturedImage;
  final void Function(bool?) onTogglePhoto;
  final VoidCallback onTakePhoto;
  final VoidCallback onViewPhoto;

  const PhotoSection({
    super.key,
    required this.isImageCaptured,
    required this.capturedImage,
    required this.onTogglePhoto,
    required this.onTakePhoto,
    required this.onViewPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          return Checkbox(
            value: isImageCaptured.value,
            onChanged: (bool? value) {
              onTogglePhoto(value);
              if (value == true && capturedImage.value == null) {
                onTakePhoto();
              }
            },
            activeColor: AppColor.blue,
          );
        }),
        const Text('Take a Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            )),
        const Spacer(),
        Obx(() {
          if (isImageCaptured.value && capturedImage.value != null) {
            return TextButton.icon(
              icon: const Icon(Icons.image, color: AppColor.white),
              onPressed: onViewPhoto,
              style: TextButton.styleFrom(
                backgroundColor: AppColor.teal,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text("View Photo",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            );
          } else {
            return const SizedBox();
          }
        }),
      ],
    );
  }
}
