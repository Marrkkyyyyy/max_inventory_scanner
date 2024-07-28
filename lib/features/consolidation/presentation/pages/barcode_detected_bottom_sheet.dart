import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/package_photo_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/widgets/image_view.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/controller/bottom_sheet_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/action_button.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/package_details_header.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/photo_section.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/problem_type_section.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/widgets/barcode_detected_bottom_sheet.dart/tracking_number_display.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/pages/view_package_photos.dart';
import 'package:shimmer/shimmer.dart';

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
  final VoidCallback onCancel;
  final String controllerTag;
  final PackagePhotoController packagePhotoController;
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
    required this.onCancel,
    required this.controllerTag,
    required this.packagePhotoController,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<BarcodeDetectedBottomSheetController>(
      tag: controllerTag,
      builder: (controller) {
        return SingleChildScrollView(
          child: Container(
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
                  onReScan: onReScan,
                ),
                const SizedBox(height: 24),
                if (controller.isPackageExist.value)
                  _buildPhotoInfoSection(controller)
                else
                  _buildPackageNotFoundWarning(),
                if (controller.isPackageExist.value)
                  PhotoSection(
                    isImageCaptured: packagePhotoController.isImageCaptured,
                    capturedImage: packagePhotoController.capturedImage,
                    onTogglePhoto: onTogglePhoto,
                    onTakePhoto: packagePhotoController.takePhoto,
                    onViewPhoto: onViewPhoto,
                  )
                else
                  buildPhotoButton(context),
                ProblemTypeSection(
                  isImageCaptured: packagePhotoController.isImageCaptured,
                  selectedProblemType:
                      packagePhotoController.selectedProblemType,
                  showOtherProblemField:
                      packagePhotoController.showOtherProblemField,
                  otherProblemController:
                      packagePhotoController.otherProblemController,
                  onProblemTypeChanged: onProblemTypeChanged,
                  onOtherProblemChanged: onOtherProblemChanged,
                ),
                const SizedBox(height: 28),
                TrackingNumberDisplay(
                    trackingNumber: packageInfo.trackingNumber),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPhotoButton(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton.icon(
            onPressed: packagePhotoController.isImageCaptured.value
                ? () => _showImageViewDialog(
                    context,
                    packagePhotoController.capturedImage.value!,
                    packagePhotoController.takePhoto)
                : packagePhotoController.takePhoto,
            icon: Icon(
              packagePhotoController.isImageCaptured.value
                  ? Icons.photo
                  : Icons.camera_alt,
              color: AppColor.white,
            ),
            label: Text(
              packagePhotoController.isImageCaptured.value
                  ? "View Photo"
                  : "Take a Photo",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: packagePhotoController.isImageCaptured.value
                    ? AppColor.teal
                    : AppColor.blue,
                side: packagePhotoController.isImageCaptured.value
                    ? BorderSide(color: AppColor.teal)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ));
  }

  void _showImageViewDialog(
      BuildContext context, File imageFile, VoidCallback onRetake) {
    Get.dialog(
      ImageViewDialog(
        imageFile: imageFile,
        onRetake: () {
          Get.back();
          onRetake();
        },
      ),
      barrierDismissible: false,
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

  Widget _buildPackageNotFoundWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.warn1.withOpacity(0.1),
        border: Border.all(color: AppColor.warn1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColor.warn1,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Package Not Found",
                  style: TextStyle(
                    color: AppColor.warn1,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "The package with this tracking number could not be found in the system. Please verify the tracking number and try again.",
                  style: TextStyle(
                    color: AppColor.warn1.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoInfoSection(
      BarcodeDetectedBottomSheetController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: controller.isLoading.value
          ? _buildShimmerPlaceholder()
          : controller.photoInfoList.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Package Photos:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.photoInfoList.length,
                        itemBuilder: (context, index) {
                          final photoInfo = controller.photoInfoList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewerPage(
                                      photoInfoList: controller.photoInfoList,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'photo_$index',
                                child: CachedNetworkImage(
                                  imageUrl: photoInfo.photoUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Package Photos:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
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
