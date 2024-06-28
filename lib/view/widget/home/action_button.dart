import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isOutlined;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _buttonContent(),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _buttonContent(),
            ),
    );
  }

  Widget _buttonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isOutlined ? color : Colors.white, size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isOutlined ? color : Colors.white,
            fontWeight: isOutlined ? FontWeight.w500 : FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
