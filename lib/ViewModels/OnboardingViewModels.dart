import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../Views/Onboarding/OnboardingOne.dart';
import '../Views/Onboarding/OnboardingThree.dart';
import '../Views/Onboarding/OnbordingTwo.dart';


class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  final List<Widget> pages = [
    OnboardingScreenOne(),
    OnboardingScreenTwo(),
    OnboardingScreenThree()
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }
}
