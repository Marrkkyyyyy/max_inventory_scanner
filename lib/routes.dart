import 'package:get/get.dart';
import 'package:max_inventory_scanner/view/screen/consolidation/consolidation_page.dart';
import 'package:max_inventory_scanner/view/screen/consolidation/consolidation_process.dart';
import 'package:max_inventory_scanner/view/screen/home/home_page.dart';

import 'core/controller/home/home_page_controller.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(name: "/", page: () => const HomePage()),
  GetPage(
      name: AppRoute.consolidationPage,
      page: () => const ConsolidationPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200)),

  GetPage(
      name: AppRoute.consolidationProcess,
      page: () => const ConsolidationProcess(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        Get.lazyPut<HomePageController>(() => HomePageController());
      }),
      transitionDuration: const Duration(milliseconds: 200)),

  // ********************** Authentication
  // GetPage(
  //     name: AppRoute.loginPage,
  //     page: () => const LoginPage(),
  //     transition: Transition.rightToLeft,
  //     transitionDuration: const Duration(milliseconds: 200)),
  // GetPage(
  //     name: AppRoute.registerPage,
  //     page: () => const RegisterPage(),
  //     transition: Transition.rightToLeft,
  //     transitionDuration: const Duration(milliseconds: 200)),
];

class AppRoute {
  // ******************** Authentication
  static const String homePage = "/homePage";
  static const String consolidationPage = "/consolidationPage";
  static const String consolidationProcess = "/consolidationProcess";
}
