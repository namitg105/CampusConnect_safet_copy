import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

class AppStyles {

  // **Dynamic Text Styles Based on Theme**
  static TextStyle socialButtonTextStyle(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.black : Colors.white,
  );

  static TextStyle textStyle(BuildContext context) => TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: context.isLightMode ? Colors.black87 : Colors.white70,
  );

  static TextStyle textStyleLargeBold(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textAddUserStyleLargeBold(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle offerStyleLarge(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.black : Colors.white,
    fontSize: 28,
  );

  static TextStyle textStyleMedium(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white70 : Colors.black54,
    fontSize: 16,
  );

  static TextStyle textStyleSmallBold(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textStyleSmall(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white70 : Colors.black54,
    fontSize: 12,
  );

  static TextStyle welcomeTextStyle(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontSize: 42,
    fontWeight: FontWeight.bold,
  );

  static TextStyle appNameTextStyle(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontSize: 38,
    fontWeight: FontWeight.bold,
  );

  static TextStyle taglineTextStyle(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.black87 : Colors.white70,
    fontSize: 38,
  );

  static TextStyle headingTextStyle(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headingTextStyleTwo(BuildContext context) => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static TextStyle goalTextStyle(BuildContext context) => TextStyle(
    fontSize: 18,
    color: context.isLightMode ? Colors.white : Colors.black,
    fontWeight: FontWeight.w700,
  );

  static TextStyle authTextStyle(BuildContext context) => TextStyle(
    fontSize: 28,
    color: context.isLightMode ? Colors.white : Colors.black,
    fontWeight: FontWeight.w700,
  );

  static TextStyle loginHeading(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle loginSubheading(BuildContext context) => TextStyle(
    fontSize: 18,
    color: context.isLightMode ? Colors.black54 : Colors.white60,
  );

  static TextStyle normalText(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white70 : Colors.black87,
    fontSize: 14,
  );

  static TextStyle boldUnderlinedText(BuildContext context) => TextStyle(
    color: context.isLightMode ? Colors.white : Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
}
