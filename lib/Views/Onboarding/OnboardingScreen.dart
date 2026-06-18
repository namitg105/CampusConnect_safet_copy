import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import '../../ViewModels/OnboardingViewModels.dart';
import '../../Widgets/Buttons/ButtonWidgets.dart';
import '../Authentication/LoginScreen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  final OnboardingController controller = Get.put(OnboardingController());
  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: lightModeController.isLightMode.value ? Colors.black : Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                return controller.pages[index];
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.pages.length,
                  (index) => buildDot(index, controller.currentPage.value),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: ButtonWidgets(
              onTap: () {
               /* Get.to(/*removed login screen for now  */);*/
              },
              buttonText: 'Next',
            ),
          ),
        ],
      ),
    ));
  }

  Widget buildDot(int index, int currentIndex) {
    final bool isDarkMode = lightModeController.isLightMode.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentIndex == index ? 54 : 28,
      height: 8,
      decoration: BoxDecoration(
        color: currentIndex == index
            ? (isDarkMode ? AppConstants.dotActiveColor : AppConstants.dotActiveColor)
            : (isDarkMode ? AppConstants.dotInactiveColor : Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
