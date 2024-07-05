import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedPreferences;
  Future<MyServices> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveSettings(String name, String location) async {
    await sharedPreferences.setString('name', name);
    await sharedPreferences.setString('location', location);
  }

  String? getName() {
    return sharedPreferences.getString('name');
  }

  String? getLocation() {
    return sharedPreferences.getString('location');
  }
}

initialServices() async {
  await Get.putAsync(() {
    return MyServices().init();
  });
}
