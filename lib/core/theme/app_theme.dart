import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: "Manrope",
          fontSize: 22,
        ),
      ),
      primarySwatch: Colors.blue,
      fontFamily: 'Manrope',
    );
  }
}