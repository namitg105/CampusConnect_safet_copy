import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Views/OnboardingScreen3.dart';
import 'package:noteswap/firebase_options.dart';
import 'ViewModels/DarkModeViewModels.dart';
import 'Views/Onboarding/OnboardingScreen.dart';
import 'Views/SplashScreen.dart';

void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(LightModeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController =
        Get.put(LightModeController());

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: darkModeController.isLightMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: '/homeScreen',
          getPages: [
            GetPage(name: '/homeScreen', page: () => Onboardingscreen3()),
            GetPage(name: '/onboardingScreen', page: () => OnboardingScreen()),
          ],
        ));
  }
}
