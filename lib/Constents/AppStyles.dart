import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ViewModels/DarkModeViewModels.dart';

class AppStyles {
  static final LightModeController lightModeController = Get.find<LightModeController>();

  // **Dynamic Text Styles Based on Theme**
  static TextStyle get socialButtonTextStyle => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.black : Colors.white,
  );

  static TextStyle get textStyle => TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: lightModeController.isLightMode.value ? Colors.black87 : Colors.white70,
  );

  static TextStyle get textStyleLargeBold => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get textAddUserStyleLargeBold => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get offerStyleLarge => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.black : Colors.white,
    fontSize: 28,
  );

  static TextStyle get textStyleMedium => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white70 : Colors.black54,
    fontSize: 16,
  );

  static TextStyle get textStyleSmallBold => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get textStyleSmall => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white70 : Colors.black54,
    fontSize: 12,
  );

  static TextStyle get welcomeTextStyle => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontSize: 42,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get appNameTextStyle => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontSize: 38,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get taglineTextStyle => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.black87 : Colors.white70,
    fontSize: 38,
  );

  static TextStyle get headingTextStyle => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headingTextStyleTwo => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get goalTextStyle => TextStyle(
    fontSize: 18,
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get authTextStyle => TextStyle(
    fontSize: 28,
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get loginHeading => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get loginSubheading => TextStyle(
    fontSize: 18,
    color: lightModeController.isLightMode.value ? Colors.black54 : Colors.white60,
  );

  static TextStyle get normalText => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white70 : Colors.black87,
    fontSize: 14,
  );

  static TextStyle get boldUnderlinedText => TextStyle(
    color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
}
