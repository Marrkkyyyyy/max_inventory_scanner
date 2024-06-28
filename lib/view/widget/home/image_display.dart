import 'package:flutter/material.dart';

import '../../../core/constant/image_asset.dart';

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(AppImageASset.mobileScan),
      ),
    );
  }
}
