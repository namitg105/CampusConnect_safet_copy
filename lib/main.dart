import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'ViewModels/DarkModeViewModels.dart';
import 'core/di/injection.dart';

import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/SplashScreen.dart';
import 'features/auth/presentation/pages/auth_page.dart';

import 'features/home/presentation/pages/main_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize GetIt
  await init();

  // Initialize Theme Controller
  Get.put(LightModeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController =
        Get.find<LightModeController>();

    return RepositoryProvider(
      create: (_) => FirebaseAuthRepo(),
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
            home: SplashScreen(),
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authState.message,
              ),
            ),
          );
        }
      },
      builder: (context, authState) {
        if (authState is Authenticated) {
          return const MainPage();
        }

        if (authState is Unauthenticated) {
          return const AuthPage();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
