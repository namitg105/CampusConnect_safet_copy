import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/posts/presentation/pages/campus_feed_screen.dart'; // Adjust import if needed
import 'package:noteswap/features/dashboard/presentation/pages/dashboard_page_one.dart';
import 'package:noteswap/features/dashboard/presentation/pages/dashboard_page_two.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void logout() {
    final authCubit = context.read<AuthCubit>();
    authCubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF6139ED);
    //  Add BlocListener here
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        //  Listen for the Unauthenticated state
        if (state is Unauthenticated) {
          // Kick the user back to the AuthPage (or AuthWrapper)
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
                /* ElevatedButton.icon(
                  onPressed: () => Get.to(() => const DashboardPageTwo()),
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Open Dashboard Screen Two'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: brandColor,
                    side: BorderSide(color: brandColor),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),*/
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const ProfileSettingsPage()),
                  icon: const Icon(Icons.person_pin),
                  label: const Text('Open Profile Settings Screen'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
