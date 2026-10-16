import 'package:get/get.dart' hide SnackPosition;
import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:noteswap/Views/Onboarding/OnboardingFlowScreen.dart';
import '../Constents/AppConstents.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(Duration(seconds: AppConstants.splashDuration), () {
      AppNavigator.replace(const OnboardingFlowScreen());
    });
  }
}
