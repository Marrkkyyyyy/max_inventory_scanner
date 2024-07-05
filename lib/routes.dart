import 'package:get/get.dart';
import 'package:max_inventory_scanner/core/controller/settings/settings_controller.dart';
import 'package:max_inventory_scanner/view/screen/consolidation/consolidation_process.dart';
import 'package:max_inventory_scanner/view/screen/home/home_page.dart';
import 'package:max_inventory_scanner/view/screen/settings/settings_page.dart';
import 'core/controller/home/home_page_controller.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(name: "/", page: () => const HomePage()),
  GetPage(
      name: AppRoute.consolidationProcess,
      page: () => const ConsolidationProcess(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        Get.lazyPut<HomePageController>(() => HomePageController());
      }),
      transitionDuration: const Duration(milliseconds: 200)),
  GetPage(
    name: AppRoute.settingsPage,
    page: () => const SettingsPage(),
    binding: BindingsBuilder(() {
      Get.lazyPut<SettingsController>(() => SettingsController());
    }),
  ),
];

class AppRoute {
  static const String homePage = "/homePage";

  static const String consolidationProcess = "/consolidationProcess";
  static const String settingsPage = "/settingsPage";
}
