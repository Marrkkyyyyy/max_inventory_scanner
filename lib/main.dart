import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'core/constant/strings.dart';
import 'core/services/http_override_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/status_bar_config.dart';
import 'dependency/dependency_injection.dart';
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  HttpOverrideService.initialize();
  await DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    StatusBarConfig.configure();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoute.HOME,
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
    );
  }
}
