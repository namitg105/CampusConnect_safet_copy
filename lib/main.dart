import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:noteswap/Views/OnboardingScreen3.dart';
import 'package:noteswap/Views/LoginScreen.dart';
import 'package:noteswap/firebase_options.dart';
import 'ViewModels/DarkModeViewModels.dart';
import 'Views/Onboarding/OnboardingScreen.dart';
import 'Views/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(LightModeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController = Get.find<LightModeController>();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      themeMode: darkModeController.isLightMode.value ? ThemeMode.light : ThemeMode.dark,
      initialRoute: '/homeScreen',
      getPages: [

        GetPage(name: '/homeScreen', page: () => const Loginscreen()),
        GetPage(name: '/onboardingScreen', page: () =>  OnboardingScreen()),
      ],
    ));
  }
}