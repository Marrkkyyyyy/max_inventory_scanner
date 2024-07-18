import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:max_inventory_scanner/core/constant/image_asset.dart';
import 'package:max_inventory_scanner/core/enums/status_result.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

class HandlingRequest extends StatelessWidget {
  final StatusResult statusRequest;
  final VoidCallback onRefresh;
  final Widget widget;

  const HandlingRequest({
    super.key,
    required this.statusRequest,
    required this.widget,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    switch (statusRequest) {
      case StatusResult.loading:
        return _buildLoadingView();
      case StatusResult.noInternet:
        return _buildErrorView(
          animation: AppImageASset.offline,
          title: "No Internet",
          messages: [
            "No internet connection found",
            "Please try again",
          ],
        );
      case StatusResult.failure:
        return _buildErrorView(
          animation: AppImageASset.server,
          title: "Server Failure",
          messages: [
            "Oops! Something went wrong",
            "Please try again",
          ],
        );
      default:
        return widget;
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Lottie.asset(AppImageASset.loading, width: 150, height: 150),
    );
  }

  Widget _buildErrorView({
    required String animation,
    required String title,
    required List<String> messages,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animation,
              repeat: false,
              width: animation == AppImageASset.offline ? 100 : 150,
              height: animation == AppImageASset.offline ? 80 : null,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black54,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            ...messages.map((message) => Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w300,
                  ),
                )),
            const SizedBox(height: 12),
            _buildTryAgainButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTryAgainButton() {
    return ElevatedButton(
      onPressed: onRefresh,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColor.blue),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.blue,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: const Text(
        'Try again',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
      ),
    );
  }
}
