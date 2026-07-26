import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:noteswap/features/auth/data/firebase_auth_repo.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
//import 'package:noteswap/features/auth/presentation/pages/SplashScreen.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';

import 'package:noteswap/features/private_chat/data/private-chat-services/user_service.dart';
import 'package:noteswap/features/private_chat/page_controller.dart';
import 'package:noteswap/firebase_options.dart';
import 'ViewModels/DarkModeViewModels.dart'; // Retained member's theme controller

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize your teammate's theme controller
  Get.put(LightModeController());
  await Get.putAsync<UserService>(() async => UserService());

  runApp(const MyApp());
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
              //home: SplashScreen(),
              home: const AuthWrapper()), //home: SplashScreen(),
        ),
      ),
    );
  }
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
          Get.find<UserService>().updateUser(authState.user);
          //return const UserDirectory();
          return const PrivateChatPageController();
          //return HomePage();
        } else if (authState is Unauthenticated) {
          Get.find<UserService>().clearUser();
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
