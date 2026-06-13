import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import '../../Constents/AppStyles.dart';
import '../../Widgets/ImageWidgets.dart';

class OnboardingScreenOne extends StatelessWidget {

  final LightModeController lightModeController = Get.put(LightModeController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        backgroundColor: lightModeController.isLightMode.value ? Colors.black : Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                AppConstants.onboardingText,
                textAlign: TextAlign.center,
                style: AppStyles.headingTextStyle,
              ),
            ),
            SizedBox(height: 20),
            ImageWidget(
              imagePath: AppConstants.onboardingFirst,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ),
    );
  }
}
