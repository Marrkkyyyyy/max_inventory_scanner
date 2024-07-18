import 'package:flutter/cupertino.dart';

class TextStyles {
  static appBarTextStyle({
    Color? textColor,
  }) {
    return TextStyle(
      color: textColor,
      fontSize: 22,
    );
  }

  static primaryTextStyle({
    Color? textColor,
  }) {
    return TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  static secondaryTextStyle({
    Color? textColor,
  }) {
    return TextStyle(
      color: textColor,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
  }
}
