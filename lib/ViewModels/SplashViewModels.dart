import 'package:get/get.dart';
import '../Constents/AppConstents.dart';
import '../Routes/AppRoutes.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(Duration(seconds: AppConstants.splashDuration), () {
      Get.offNamed(AppRoutes.home);
    });
  }
}
