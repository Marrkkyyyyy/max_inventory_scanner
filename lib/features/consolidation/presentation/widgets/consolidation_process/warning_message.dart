import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class WarningMessage extends StatelessWidget {
  final bool isNewBox;
  final bool packageExists;

  const WarningMessage({
    super.key,
    required this.isNewBox,
    required this.packageExists,
  });

  @override
  Widget build(BuildContext context) {
    if (!isNewBox && !packageExists) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColor.warn1.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.warn1.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColor.warn1.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColor.warn1,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Package Not Found",
                    style: TextStyle(
                      color: AppColor.warn1,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: "• If "),
                        TextSpan(
                          text: "existing",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.warn1,
                          ),
                        ),
                        TextSpan(text: ": please take a photo.\n"),
                        TextSpan(text: "• If "),
                        TextSpan(
                          text: "new",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.warn1,
                          ),
                        ),
                        TextSpan(
                            text: ": please use the scanner for the new box."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
}
