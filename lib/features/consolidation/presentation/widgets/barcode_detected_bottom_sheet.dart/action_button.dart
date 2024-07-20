import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final bool isPrimary;
  final Color? color;
  final bool hasBorder;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.isPrimary,
    this.color,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (isPrimary ? AppColor.blue : AppColor.white);
    final textColor = color ?? (isPrimary ? AppColor.white : AppColor.blue);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor, size: 24),
      label: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: hasBorder
                ? AppColor.blue
                : (isPrimary ? Colors.transparent : buttonColor),
            width: 1.5,
          ),
        ),
        elevation: isPrimary ? 3 : 0,
      ),
    );
  }
}
