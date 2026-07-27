import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import '../../ViewModels/OnboardingViewModels.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          OnboardingPageLayout(
            pageIndex: 0,
            imagePath: "assets/images_intro/Splash_page_2_image.png",
            title: "Real-time Conversations",
            subtitle: "Chat, discuss, and stay updated in organized channels for every topic that matters.",
            controller: controller,
          ),
          OnboardingPageLayout(
            pageIndex: 1,
            imagePath: "assets/images_intro/Splash_page_3_image-1.png",
            title: "Join & Create Communities",
            subtitle: "Discover clubs, sports teams, and academic groups or create your own community.",
            controller: controller,
          ),
          OnboardingPageLayout(
            pageIndex: 2,
            imagePath: "assets/Gemini_Generated_Image_s38k7zs38k7zs38k 1.png",
            bottomIconPath: "assets/notes 1.png",
            title: "Share & Access Resourses",
            subtitle: "Get course notes, important resourses,\nand study materials shared by seniors.",
            controller: controller,
          ),
        ],
      ),
    );
  }
}

class OnboardingPageLayout extends StatelessWidget {
  final int pageIndex;
  final String imagePath;
  final String? bottomIconPath;
  final String title;
  final String subtitle;
  final OnboardingController controller;

  const OnboardingPageLayout({
    super.key,
    required this.pageIndex,
    required this.imagePath,
    this.bottomIconPath,
    required this.title,
    required this.subtitle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Top-left icon background
        Positioned(
          top: 0,
          left: 0,
          child: Image.asset(
            "assets/Icon l-r.png",
            width: MediaQuery.of(context).size.width * 0.65,
            fit: BoxFit.contain,
          ),
        ),
        // Top-right background decoration (for pageIndex 2, and others if needed)
        Positioned(
          top: 450,
          right: 0,
          child: Image.asset(
            "assets/Icon.png",
            width: MediaQuery.of(context).size.width * 0.65,
            fit: BoxFit.contain,
          ),
        ),
        // Central Illustration
        Positioned(
          top: screenHeight * 0.12,
          left: -20,
          right: -20,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            height: screenHeight * 0.45,
          ),
        ),
        // Header (Logo + Skip)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/Heading.png",
                  width: 220,
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAll(() => const AuthPage());
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6139ED),
                        letterSpacing: -1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Content
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, left: 24.0, right: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomIconPath != null) ...[
                  Image.asset(
                    bottomIconPath!,
                    width: 104,
                    height: 97,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // Keep spacing consistent if no bottom icon
                  const SizedBox(height: 40),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A68),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                // Pagination Dots Row
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = controller.currentPage.value == index;
                      return GestureDetector(
                        onTap: () {
                          controller.pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 24 : 16,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF6139ED)
                                : const Color(0xFF9E9EA7).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
