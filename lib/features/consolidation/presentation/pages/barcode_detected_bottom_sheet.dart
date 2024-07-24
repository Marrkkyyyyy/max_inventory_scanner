import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/action_button.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/package_details_header.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/photo_section.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/problem_type_section.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/tracking_number_display.dart';

class BarcodeDetectedBottomSheet extends StatelessWidget {
  final PackageInfo packageInfo;
  final bool isEditing;
  final VoidCallback onSaveAndExit;
  final VoidCallback onSaveAndNext;
  final VoidCallback? onUpdate;
  final VoidCallback? onRemove;
  final VoidCallback onReScan;
  final void Function(bool?) onTogglePhoto;
  final Function() onTakePhoto;
  final Function() onViewPhoto;
  final Function(String?) onProblemTypeChanged;
  final Function(String) onOtherProblemChanged;
  final RxBool isImageCaptured;
  final Rx<File?> capturedImage;
  final Rx<String?> selectedProblemType;
  final RxBool showOtherProblemField;
  final TextEditingController otherProblemController;
  final VoidCallback onCancel;

  const BarcodeDetectedBottomSheet({
    super.key,
    required this.packageInfo,
    required this.isEditing,
    required this.onSaveAndExit,
    required this.onSaveAndNext,
    this.onUpdate,
    this.onRemove,
    required this.onReScan,
    required this.onTogglePhoto,
    required this.onTakePhoto,
    required this.onViewPhoto,
    required this.onProblemTypeChanged,
    required this.onOtherProblemChanged,
    required this.isImageCaptured,
    required this.capturedImage,
    required this.selectedProblemType,
    required this.showOtherProblemField,
    required this.otherProblemController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDragHandle(),
          PackageDetailsHeader(
            isEditing: isEditing,
            onRemove: onRemove,
            onReScan: () {
              onReScan();
            },
          ),
          const SizedBox(height: 24),
          PhotoSection(
            isImageCaptured: isImageCaptured,
            capturedImage: capturedImage,
            onTogglePhoto: onTogglePhoto,
            onTakePhoto: onTakePhoto,
            onViewPhoto: onViewPhoto,
          ),
          ProblemTypeSection(
            isImageCaptured: isImageCaptured,
            selectedProblemType: selectedProblemType,
            showOtherProblemField: showOtherProblemField,
            otherProblemController: otherProblemController,
            onProblemTypeChanged: onProblemTypeChanged,
            onOtherProblemChanged: onOtherProblemChanged,
          ),
          const SizedBox(height: 28),
          TrackingNumberDisplay(trackingNumber: packageInfo.trackingNumber),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEditing)
          ActionButton(
            onPressed: onUpdate!,
            text: 'Update',
            icon: Icons.update,
            isPrimary: true,
          )
        else
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  onPressed: onSaveAndExit,
                  text: 'Save & Exit',
                  icon: Icons.check_circle_outline,
                  isPrimary: true,
                  hasBorder: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActionButton(
                  onPressed: onSaveAndNext,
                  text: 'Save & Next',
                  icon: Icons.save_alt_rounded,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        ActionButton(
          onPressed: onCancel,
          text: 'Cancel',
          icon: Icons.cancel_outlined,
          isPrimary: false,
          hasBorder: true,
        ),
      ],
    );
  }
}
