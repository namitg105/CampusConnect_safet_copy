import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/data/firebase_auth_repo.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/SplashScreen.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/home/presentation/pages/home_page.dart';
import 'package:noteswap/firebase_options.dart';
import 'ViewModels/DarkModeViewModels.dart'; // Retained member's theme controller
import 'dart:ui';


void main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Only initialize Firebase if it hasn't been initialized yet
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app') || e.toString().contains('duplicate-app-name')) {
      debugPrint('Firebase App already exists, ignoring duplicate-app exception.');
    } else {
      rethrow;
    }
  }
  // Initialize your teammate's theme controller
  Get.put(LightModeController());

  // 3. Run your app
  runApp(const MyApp()); // Replace MyApp() with whatever your root widget is named
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController =
        Get.find<LightModeController>();

    // 1. Provide the Authentication Data Layer Repository at the top
    return RepositoryProvider(
      create: (context) => FirebaseAuthRepo(),
      child: MultiBlocProvider(
        providers: [
          // 2. Instantiate AuthCubit and instantly check authentication state
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepo: context.read<FirebaseAuthRepo>(),
            )..checkAuth(),
          ),
        ],
        // 3. Keep GetMaterialApp so your teammate's reactive dark mode works cleanly
        child: Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: darkModeController.isLightMode.value
                ? ThemeMode.light
                : ThemeMode.dark,
            scrollBehavior: MyCustomScrollBehavior(),

            // 4. Set the Splash Screen as the absolute first view
            home: SplashScreen(),
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

/// A wrapper view that dynamically directs the user based on their login status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${authState.message}")),
          );
        }
      },
      builder: (context, authState) {
        print("Current UI Auth State: $authState");
        if (authState is Authenticated) {
          return const HomePage();
        } else if (authState is Unauthenticated) {
          return const AuthPage();
        }

        // Handles loading or initial authentication state resolution
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6139ED),
            ),
          ),
        );
      },
    );
  }
}

/*
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
*/
