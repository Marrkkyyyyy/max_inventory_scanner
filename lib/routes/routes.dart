import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/consolidation_process.dart';
import 'package:max_inventory_scanner/features/home/controller/home_controller.dart';
import 'package:max_inventory_scanner/features/home/presentation/pages/home.dart';
import 'package:max_inventory_scanner/features/package_details/data/repository/package_repository.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/controller/package_details_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/pages/package_details.dart';
import 'package:max_inventory_scanner/features/registration/data/repository/registration_repository.dart';
import 'package:max_inventory_scanner/features/registration/presentation/page/registration_page.dart';
import 'package:max_inventory_scanner/features/registration/presentation/controller/registration_controller.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoute.HOME,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoute.PACKAGE_DETAILS,
      page: () => const PackageDetailsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PackageRepository>(
            () => PackageRepositoryImpl(Get.find<FirebaseFirestore>()));
        Get.lazyPut<PackageDetailsController>(
            () => PackageDetailsController(Get.find<PackageRepository>()));
      }),
    ),
    GetPage(
      name: AppRoute.CONSOLIDATION,
      page: () => const ConsolidationProcess(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ConsolidationRepository>(
            () => ConsolidationRepositoryImpl(Get.find<FirebaseFirestore>()));
        Get.lazyPut<ConsolidationProcessController>(() =>
            ConsolidationProcessController(
                Get.find<ConsolidationRepository>()));
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoute.SETTINGS,
      page: () => const RegistrationPage(),
      binding: BindingsBuilder(() {
          Get.lazyPut<UserRepository>(
            () => UserRepositoryImpl(Get.find<FirebaseFirestore>()));
        Get.lazyPut<RegistrationController>(() => RegistrationController(Get.find<UserRepository>()));
      }),
    ),
  ];
}

abstract class AppRoute {
  static const HOME = '/';
  static const PACKAGE_DETAILS = '/package-details';
  static const CONSOLIDATION = '/consolidation';
  static const SETTINGS = '/settings';
}
