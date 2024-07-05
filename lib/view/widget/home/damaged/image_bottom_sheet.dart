import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/utils/custom_scanner.dart';
import 'package:max_inventory_scanner/view/widget/home/damaged/view_image.dart';

class ImageBottomSheet extends StatelessWidget {
  final HomePageController controller;

  const ImageBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 32),
                _buildTrackingNumberTextField(context),
                const SizedBox(height: 24),
                _buildDropdown(),
                Obx(() {
                  if (controller.selectedIssue.value == 'Other') {
                    return _buildOtherIssueTextField();
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 24),
                _buildImagePreview(),
                const SizedBox(height: 32),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Report Package Issue',
      style: TextStyle(
        color: AppColor.darkBlue,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      'Please provide details about the package issue you want to report.',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTrackingNumberTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tracking Number',
          style: TextStyle(
            color: AppColor.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.reportTrackingNumberController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter Tracking Number',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: IconButton(
                onPressed: () => showScannerDialog(context),
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColor.blue,
                ),
              ),
            ),
            style: const TextStyle(color: AppColor.darkBlue, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issue Type',
          style: TextStyle(
            color: AppColor.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.selectedIssue.value.isNotEmpty
                ? controller.selectedIssue.value
                : null,
            style: const TextStyle(
              fontSize: 16,
              color: AppColor.darkBlue,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
              hintText: 'Select an issue',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            items: controller.issueItems
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: controller.setSelectedIssue,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherIssueTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specify Issue',
            style: TextStyle(
              color: AppColor.darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller.otherIssueController,
              decoration: InputDecoration(
                hintText: 'Please describe the issue',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(color: AppColor.darkBlue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Obx(() {
      if (controller.imagePath.isNotEmpty) {
        return GestureDetector(
          onTap: () {
            Navigator.of(Get.context!).push(MaterialPageRoute(
              builder: (context) =>
                  ViewImage(image: controller.imagePath.value),
            ));
          },
          child: Hero(
            tag: controller.imagePath.value,
            child: Container(
              height: MediaQuery.of(Get.context!).size.height * .3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(controller.imagePath.value)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            onPressed: () async {
              await controller.canelReportIssue();
              Navigator.of(context).pop();
            },
            text: 'Cancel',
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(
            onPressed: () async {
              await controller.reportIssue();
              if (controller.imagePath.isEmpty) {
                Navigator.of(context).pop();
              }
            },
            text: 'Report Issue',
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColor.blue : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColor.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : AppColor.blue,
            width: 1.5,
          ),
        ),
        elevation: isPrimary ? 3 : 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }

  void showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomScanner(
        onBarcodeDetected: (barcode) {
          Navigator.of(context).pop();
          controller.detectBarcode(barcode);
        },
      ),
    );
  }
}
