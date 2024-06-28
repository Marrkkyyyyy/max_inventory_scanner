import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarService {
  static bool _isSnackbarActive = false;

  static void showCustomSnackbar({
    required String title,
    required String message,
    Color backgroundColor = Colors.red,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!_isSnackbarActive) {
      _isSnackbarActive = true;
      Get.snackbar(
        title,
        message,
        margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
        snackPosition: SnackPosition.TOP,
        backgroundColor: backgroundColor,
        colorText: textColor,
        duration: duration,
        onTap: (_) {
          _isSnackbarActive = false;
          Get.closeCurrentSnackbar();
        },
        isDismissible: true,
      );

      Future.delayed(duration, () {
        _isSnackbarActive = false;
      });
    }
  }
}
