import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/controller/package_details_controller.dart';

class PackageActionButtonsWidget extends GetView<PackageDetailsController> {
  const PackageActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  onPressed: () => controller.processAndSavePackage(),
                  text: 'Save & Exit',
                  icon: Icons.check_circle_outline,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildButton(
                  onPressed: () =>
                      controller.processAndSavePackage(exitAfterSave: false),
                  text: 'Save & Next',
                  icon: Icons.save_alt_rounded,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon,
          color: isPrimary ? AppColor.white : AppColor.blue, size: 24),
      label: Text(
        text,
        style: TextStyle(
          color: isPrimary ? AppColor.white : AppColor.blue,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColor.blue : AppColor.white,
        foregroundColor: isPrimary ? AppColor.white : AppColor.blue,
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
    );
  }
}
