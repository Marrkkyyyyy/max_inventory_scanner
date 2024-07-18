import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarConfig {
  static void configure() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
}
