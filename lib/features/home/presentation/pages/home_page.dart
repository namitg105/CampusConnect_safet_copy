import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/posts/presentation/pages/campus_feed_screen.dart';
import 'package:noteswap/features/dashboard/presentation/pages/dashboard_page_one.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';
import 'package:noteswap/features/auth/presentation/pages/SplashScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void logout() async {
    await context.read<AuthCubit>().logout();
    Get.offAll(() => const SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF6139ED);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Get.offAll(() => const AuthPage());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const CampusFeedScreen()),
                    icon: const Icon(Icons.feed),
                    label: const Text('Open Campus Feed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const DashboardPageOne()),
                    icon: const Icon(Icons.dashboard_customize),
                    label: const Text('Open Dashboard Screen One'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: brandColor,
                      side: BorderSide(color: brandColor),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (Get.isRegistered<MainPageController>()) {
                        Get.find<MainPageController>().changeIndex(1);
                      } else {
                        final controller = Get.put(MainPageController());
                        controller.changeIndex(1);
                        Get.offAll(() => const MainPage());
                      }
                    },
                    icon: const Icon(Icons.group_outlined),
                    label: const Text('Open Community Pages'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
