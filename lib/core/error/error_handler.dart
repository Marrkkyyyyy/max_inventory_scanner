// lib/core/error/error_handler.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../enums/status_result.dart';
import '../utils/snackbar_service.dart';

class ErrorHandler {
  static void handleError(StatusResult result) {
    switch (result) {
      case StatusResult.noInternet:
        _showNoInternetError();
        break;
      case StatusResult.failure:
        _showSaveFailedError();
        break;
      default:
        break;
    }
  }

  static Future<void> handleConsolidationError(StatusResult result) async {
    switch (result) {
      case StatusResult.success:
        await _showConsolidationSuccess();
        break;
      case StatusResult.noInternet:
        _showNoInternetError();
        break;
      case StatusResult.failure:
        _showConsolidationFailedError();
        break;
      case StatusResult.notFound:
        _showPackagesNotFoundError();
        break;
      default:
        EasyLoading.dismiss();
        break;
    }
  }

  static void _showNoInternetError() {
    EasyLoading.dismiss();
    SnackbarService.showCustomSnackbar(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      backgroundColor: Colors.red,
    );
  }

  static void _showSaveFailedError() {
    SnackbarService.showCustomSnackbar(
      title: 'Save Failed',
      message: 'Failed to save package. Please try again.',
      backgroundColor: Colors.red,
    );
  }

  static Future<void> _showConsolidationSuccess() async {
    EasyLoading.dismiss();
    EasyLoading.showSuccess('Consolidation Successful',
        duration: const Duration(seconds: 2));
    await Future.delayed(const Duration(seconds: 2));
    Get.back();
  }

  static void _showConsolidationFailedError() {
    EasyLoading.dismiss();
    SnackbarService.showCustomSnackbar(
      title: 'Consolidation Failed',
      message: 'An error occurred during consolidation. Please try again.',
      backgroundColor: Colors.red,
    );
  }

  static void _showPackagesNotFoundError() {
    EasyLoading.dismiss();
    SnackbarService.showCustomSnackbar(
      title: "Consolidation Failed",
      message: "Some packages were not found",
      backgroundColor: Colors.red,
    );
  }
}
