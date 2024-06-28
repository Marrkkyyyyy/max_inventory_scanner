// error_handler.dart
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/class/service_result.dart';

import '../../utils/snackbar_service.dart';

class ErrorHandler {
  static void handleError(PackageResult result) {
    switch (result) {
      case PackageResult.noInternet:
        SnackbarService.showCustomSnackbar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.',
          backgroundColor: Colors.red,
        );
        break;
      case PackageResult.failure:
        SnackbarService.showCustomSnackbar(
          title: 'Save Failed',
          message: 'Failed to save package. Please try again.',
          backgroundColor: Colors.red,
        );
        break;
      default:
        // Do nothing for success case
        break;
    }
  }
}
