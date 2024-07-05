import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'core/services/services.dart';
import 'routes.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent, // Make status bar transparent
  statusBarIconBrightness: Brightness.dark, // Use dark icons for better visibility
));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Max Inventory Scanner',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: "Manrope",
                fontSize: 22)),
        primarySwatch: Colors.blue,
        fontFamily: 'Manrope',
      ),
      getPages: routes,
      builder: EasyLoading.init(),
    );
  }
}
