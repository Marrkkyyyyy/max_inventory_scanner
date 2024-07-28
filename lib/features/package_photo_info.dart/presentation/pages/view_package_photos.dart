import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/model/package_photo_info_model.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/presentation/controller/package_photos_controller.dart';
import 'package:shimmer/shimmer.dart';

class PhotoViewerPage extends StatelessWidget {
  final List<PackagePhotoInfo> photoInfoList;
  final int initialIndex;

  const PhotoViewerPage({
    super.key,
    required this.photoInfoList,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhotoViewerController(initialIndex));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              itemCount: photoInfoList.length,
              controller: PageController(initialPage: initialIndex),
              onPageChanged: (int index) {
                controller.currentPage.value = index;
              },
              itemBuilder: (context, index) {
                final photoInfo = photoInfoList[index];
                return Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'photo_$index',
                          child: CachedNetworkImage(
                            imageUrl: photoInfo.photoUrl,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[800]!,
                              highlightColor: Colors.grey[600]!,
                              child: Container(
                                color: Colors.grey[700],
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${photoInfo.status ?? 'Unknown'}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Problem: ${photoInfo.problemType ?? 'None'}',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 12),
                  Obx(() {
                    return Text(
                      '${controller.currentPage.value + 1}/${photoInfoList.length}',
                      style: const TextStyle(color: Colors.white),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
