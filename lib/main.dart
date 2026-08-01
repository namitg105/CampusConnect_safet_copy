import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/data/firebase_auth_repo.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/SplashScreen.dart';
import 'package:noteswap/features/private_chat/data/private-chat-services/user_service.dart';
import 'package:noteswap/firebase_options.dart';
import 'ViewModels/DarkModeViewModels.dart'; // Retained member's theme controller
import 'core/di/injection.dart'; // DI injection init
import 'ViewModels/NotificationController.dart';
import 'features/home/presentation/pages/main_page.dart'; // MainPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app') ||
        e.toString().contains('duplicate-app-name')) {
      debugPrint(
          'Firebase App already exists, ignoring duplicate-app exception.');
    } else {
      rethrow;
    }
  }

  // Initialize service locator
  await init();

  // Initialize controllers
  Get.put(LightModeController());
  Get.put(NotificationController());
  await Get.putAsync<UserService>(() async => UserService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController =
        Get.find<LightModeController>();

    return RepositoryProvider(
      create: (context) => FirebaseAuthRepo(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepo: context.read<FirebaseAuthRepo>(),
            )..checkAuth(),
          ),
        ],
        child: Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: darkModeController.isLightMode.value
                ? ThemeMode.light
                : ThemeMode.dark,
            scrollBehavior: MyCustomScrollBehavior(),
            home: const AuthWrapper(),
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
          Get.find<UserService>().updateUser(authState.user);
          return const MainPage(); // Land on MainPage (includes bottom navigation)
        } else if (authState is Unauthenticated) {
          Get.find<UserService>().clearUser();
          return const SplashScreen();
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
