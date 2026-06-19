import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/pages/SplashScreen.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/firebase_options.dart';

import 'ViewModels/DarkModeViewModels.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(LightModeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController =
        Get.find<LightModeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),

        // Fixed theme mode logic
        themeMode: darkModeController.isLightMode.value
            ? ThemeMode.light
            : ThemeMode.dark,

        initialRoute: '/homeScreen',

        getPages: [
          GetPage(
            name: '/homeScreen',
            page: () => SplashScreen(),
          ),
        ],
      ),
    );
  }
}
