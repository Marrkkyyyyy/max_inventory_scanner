import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/routes.dart';
import 'package:max_inventory_scanner/view/widget/consolidation/consolidation_widgets.dart';
import 'package:max_inventory_scanner/view/widget/home/home_widgets.dart';
import '../../widget/home/action_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePageController());

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: const Text(
          "MAX SHIPPING SCANNER",
          style:
              TextStyle(color: AppColor.darkBlue, fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Get.toNamed(AppRoute.settingsPage);
              },
              icon: const Icon(
                CupertinoIcons.settings,
                size: 24,
                color: AppColor.darkBlue,
              ))
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return controller.location.value == 'Consolidation'
              ? _buildConsolidation(context, controller)
              : _buildHomePage(context, controller);
        }
      }),
    );
  }

  Widget _buildHomePage(BuildContext context, HomePageController controller) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 20),
        child: Column(
          children: [
            customHeader(controller.name.value, controller.location.value),
            const SizedBox(height: 12),
            imageDisplay(),
            const SizedBox(height: 12),
            ActionButton(
              text: 'SCAN',
              icon: Icons.qr_code_scanner,
              color: AppColor.blue,
              onPressed: () => showScannerAndBottomSheet(context, controller),
            ),
            const SizedBox(height: 12),
            ActionButton(
              text: 'MANUAL ENTRY',
              icon: Icons.keyboard_alt,
              color: AppColor.blue,
              onPressed: () => showTrackingNumberEntry(context, controller),
              isOutlined: true,
            ),
            const SizedBox(height: 12),
            ActionButton(
              text: 'TAKE A PICTURE',
              icon: Icons.camera_alt,
              color: AppColor.darkRed,
              onPressed: () =>
                  takePictureAndShowBottomSheet(context, controller),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsolidation(
      BuildContext context, HomePageController controller) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            customHeader(controller.name.value, controller.location.value),
            const SizedBox(height: 20),
            buildConsolidationContent(context),
          ],
        ),
      ),
    );
  }
}
