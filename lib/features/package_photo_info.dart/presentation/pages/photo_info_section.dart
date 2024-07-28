import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/controller/bottom_sheet_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/pages/view_package_photos.dart';

class PhotoInfoSection extends GetView<BarcodeDetectedBottomSheetController> {
  const PhotoInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: controller.isLoading.value
          ? _buildShimmerPlaceholder()
          : controller.photoInfoList.isEmpty
              ? const Text(
                  'No package photos found.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
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
}
