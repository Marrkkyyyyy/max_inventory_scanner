import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/constant/color.dart';
import 'package:max_inventory_scanner/core/controller/home/home_page_controller.dart';
import 'package:max_inventory_scanner/routes.dart';
import 'package:max_inventory_scanner/view/widget/home/home_widgets.dart';
import '../../widget/home/action_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePageController());

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColor.blue3,
        centerTitle: true,
        title: const Text("Max Inventory Scanner"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
          child: Column(
            children: [
              dropdownSelector(controller),
              const SizedBox(height: 12),
              imageDisplay(),
              const SizedBox(height: 12),
              ActionButton(
                text: 'SCAN',
                icon: Icons.qr_code_scanner,
                color: AppColor.blue2,
                onPressed: () => showScannerAndBottomSheet(context, controller),
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'MANUAL ENTRY',
                icon: Icons.keyboard_alt,
                color: AppColor.blue2,
                onPressed: () => showTrackingNumberEntry(context, controller),
                isOutlined: true,
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'CONSOLIDATION',
                icon: Icons.inventory_2_rounded,
                color: AppColor.blue2,
                onPressed: () => Get.toNamed(AppRoute.consolidationPage),
                isOutlined: true,
              ),
              const SizedBox(height: 12),
              ActionButton(
                text: 'TAKE A PICTURE',
                icon: Icons.camera_alt,
                color: AppColor.darkRed,
                onPressed: () => takePictureAndShowBottomSheet(context, controller),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
