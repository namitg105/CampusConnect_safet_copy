import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../ViewModels/SplashViewModels.dart';
import '../Widgets/ImageWidgets.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashController controller = Get.put(SplashController());
  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightModeController.isLightMode.value ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppConstants.welcomeText, style: AppStyles.welcomeTextStyle),
            SizedBox(height: 5),
            Text(AppConstants.appName, style: AppStyles.appNameTextStyle),
            SizedBox(height: 30),
            ImageWidget(imagePath: AppConstants.splashLogo, fit: BoxFit.fitWidth),
            SizedBox(height: 30),
            Text(AppConstants.tagline, style: AppStyles.authTextStyle),
          ],
        ),
      ),
    );
  }
}


