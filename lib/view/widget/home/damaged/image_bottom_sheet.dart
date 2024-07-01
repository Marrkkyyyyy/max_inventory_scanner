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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const Divider(height: 30),
              _buildTrackingNumberTextfield(context),
              const SizedBox(height: 12),
              _buildDropdown(),
              Obx(() {
                if (controller.selectedIssue.value == 'Other') {
                  return _buildOtherIssueTextField();
                }
                return const SizedBox.shrink();
              }),
              _buildImagePreview(),
              _buildButtons(context),
              const SizedBox(height: 24)
            ],
          ),
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

  Widget _buildTitle() {
    return const Text(
      'Report Issue',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTrackingNumberTextfield(BuildContext context) {
    return TextField(
      controller: controller.reportTrackingNumberController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Tracking No.",
        suffixIcon: IconButton(
          onPressed: () => showScannerDialog(context),
          icon: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 24,
            color: AppColor.blue3,
          ),
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintText: 'Enter Tracking No.',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.blue2, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: DropdownButtonFormField<String>(
        value: controller.selectedIssue.value.isNotEmpty
            ? controller.selectedIssue.value
            : null,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: "Manrope",
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        hint: const Text('Select an issue'),
        items: controller.issueItems
            .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: controller.setSelectedIssue,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Please select an issue';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOtherIssueTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextField(
        controller: controller.otherIssueController,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          hintText: 'Please specify the issue',
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.blue4)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.blue4)),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Obx(() {
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
              child: Image.file(
                File(controller.imagePath.value),
                height: MediaQuery.of(Get.context!).size.height * .3,
                fit: BoxFit.contain,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await controller.canelReportIssue();
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColor.blue2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColor.blue2,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await controller.reportIssue();
              if (controller.imagePath.isEmpty) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColor.blue2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Report',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
