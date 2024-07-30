import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/services/client_service.dart';
import 'package:max_inventory_scanner/core/services/image_service.dart';
import 'package:max_inventory_scanner/features/consolidation/data/repository/consolidation_repository.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/client_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/consolidation_process_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/controller/sub_controller/package_photo_controller.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/consolidation.dart';
import 'package:max_inventory_scanner/features/consolidation/presentation/pages/consolidation_process.dart';
import 'package:max_inventory_scanner/features/home/controller/home_controller.dart';
import 'package:max_inventory_scanner/features/home/presentation/pages/home.dart';
import 'package:max_inventory_scanner/features/package_details/data/repository/package_repository.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/controller/package_details_controller.dart';
import 'package:max_inventory_scanner/features/package_details/presentation/pages/package_details.dart';
import 'package:max_inventory_scanner/features/package_photo_info.dart/data/repository/package_photo_repository.dart';
import 'package:max_inventory_scanner/features/registration/data/repository/registration_repository.dart';
import 'package:max_inventory_scanner/features/registration/presentation/page/registration_page.dart';
import 'package:max_inventory_scanner/features/registration/presentation/controller/registration_controller.dart';
import 'package:max_inventory_scanner/core/services/tracking_number_search_service.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoute.HOME,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.put<TrackingNumberSearchService>(
            TrackingNumberSearchService(Get.find<FirebaseFirestore>()));
        Get.lazyPut<HomeController>(
            () => HomeController(Get.find<TrackingNumberSearchService>()));
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
      page: () => const ConsolidationPage(),
      binding: BindingsBuilder(() {
        Get.put<TrackingNumberSearchService>(
            TrackingNumberSearchService(Get.find<FirebaseFirestore>()));
        Get.lazyPut<ConsolidationRepository>(
            () => ConsolidationRepositoryImpl(Get.find<FirebaseFirestore>()));
        Get.lazyPut<ConsolidationController>(() => ConsolidationController(
              Get.find<TrackingNumberSearchService>(),
              Get.find<ConsolidationRepository>(),
            ));
      }),
    ),
    GetPage(
      name: AppRoute.CONSOLIDATION_PROCCESS,
      page: () => const ConsolidationProcess(),
      binding: BindingsBuilder(() {
        // Services
        Get.put<ClientService>(ClientService());
        Get.put<ImageService>(ImageService());
        
        Get.put<TrackingNumberSearchService>(
            TrackingNumberSearchService(Get.find<FirebaseFirestore>()));
        Get.put<PackagePhotoRepository>(
            PackagePhotoRepositoryImpl(Get.find<FirebaseFirestore>()));
        Get.lazyPut<ConsolidationRepository>(
            () => ConsolidationRepositoryImpl(Get.find<FirebaseFirestore>()));

        // Controllers
        Get.lazyPut<ConsolidationProcessController>(
            () => ConsolidationProcessController(
                  Get.find<ConsolidationRepository>(),
                  Get.find<TrackingNumberSearchService>(),
                  Get.find<PackagePhotoRepository>(),
                ));

        // Sub-controllers
        Get.lazyPut<ClientController>(
            () => ClientController(Get.find<ClientService>()));
        Get.lazyPut<PackagePhotoController>(
            () => PackagePhotoController(Get.find<ImageService>()));
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
        Get.lazyPut<RegistrationController>(
            () => RegistrationController(Get.find<UserRepository>()));
      }),
    ),
  ];
}

abstract class AppRoute {
  static const HOME = '/';
  static const CONSOLIDATION = '/CONSOLIDATION';
  static const PACKAGE_DETAILS = '/package-details';
  static const CONSOLIDATION_PROCCESS = '/CONSOLIDATION_PROCCESS';
  static const SETTINGS = '/settings';
}
