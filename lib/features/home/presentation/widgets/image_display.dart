import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';

Widget imageDisplay() {
  return Material(
    elevation: 2,
    borderRadius: BorderRadius.circular(8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(AppImageASset.mobileScan),
    ),
  );
}
