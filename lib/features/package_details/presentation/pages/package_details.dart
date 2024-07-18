import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/core/widgets/handling_request.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/controller/package_details_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/barcode_details.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/client_name_field.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/package_action_button.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/problem_section.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/warning.dart';

class PackageDetailsPage extends GetView<PackageDetailsController> {
  const PackageDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Package Details'),
          backgroundColor: AppColor.blue,
          foregroundColor: AppColor.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: AppColor.white),
              onPressed: () => controller.onReScan(),
            ),
          ],
        ),
        body: GetBuilder<PackageDetailsController>(
          builder: (controller) {
            return HandlingRequest(
              onRefresh: controller.onRefresh,
              statusRequest: controller.statusRequest,
              widget: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ProblemSection(),
                        const Divider(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const ClientNameFieldWidget(),
                        const SizedBox(height: 16),
                        BarcodeDetailsWidget(
                          logistic: controller.logistic,
                          displayTrackingNumber:
                              controller.displayTrackingNumber,
                        ),
                        _buildWarnings(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        bottomSheet: const PackageActionButtonsWidget(),
      ),
    );
  }

  Widget _buildWarnings() {
    return Column(
      children: [
        Obx(() {
          if (controller.note.value.isNotEmpty) {
            return Column(
              children: [
                const SizedBox(height: 16),
                WarningWidget(
                  title: 'Package Note',
                  message: controller.note.value,
                  color: Colors.teal.shade600,
                  icon: Icons.info,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
       Obx(() {
        if (controller.showDuplicateWarning.value) {
          return const Column(
            children: [
              SizedBox(height: 16),
              WarningWidget(
                title: 'Duplicate Package',
                message: 'This package has already been scanned',
                color: AppColor.darkRed,
                icon: Icons.content_copy,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
        Obx(() {
          if (controller.showUnknownCarrier.value &&
              controller.logistic == 'Unknown') {
            return const Column(
              children: [
                SizedBox(height: 16),
                WarningWidget(
                  title: 'Unknown Carrier',
                  message:
                      'Unknown carrier detected. Please take a photo of the whole label.',
                  color: Colors.orange,
                  icon: Icons.warning,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
