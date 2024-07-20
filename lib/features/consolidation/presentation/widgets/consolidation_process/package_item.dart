import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';
import 'package:max_inventory_scanner/features/consolidation/data/model/package_info_model.dart';

class PackageItem extends StatelessWidget {
  final PackageInfo packageInfo;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const PackageItem({
    super.key,
    required this.packageInfo,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(packageInfo.trackingNumber),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      child: Card(
        color: AppColor.white,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColor.blue),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: const Icon(Icons.inventory_2, color: AppColor.blue),
            title: Text(
              packageInfo.trackingNumber,
              style: const TextStyle(fontSize: 16, color: AppColor.darkBlue),
            ),
            subtitle: packageInfo.problemType != null
                ? Text(
                    packageInfo.problemType!,
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  )
                : null,
            trailing: packageInfo.image != null
                ? Icon(Icons.image, color: AppColor.teal)
                : null,
          ),
        ),
      ),
    );
  }
}
