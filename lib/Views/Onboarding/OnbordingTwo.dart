import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'OnboardingThree.dart';

class OnboardingScreenTwo extends StatelessWidget {
  const OnboardingScreenTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swiped Left -> Go to Page 3
            Get.to(
              () => const OnboardingScreenThree(),
              transition: Transition.rightToLeft,
            );
          } else if (details.primaryVelocity! > 0) {
            // Swiped Right -> Back to Page 1
            Get.back();
          }
        },
        child: Stack(
          children: [
            // Top-left icon background
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/Icon l-r.png",
                width: screenWidth * 0.7,
                fit: BoxFit.contain,
              ),
            ),
            // Top-right background decoration
            Positioned(
              top: screenHeight * 0.46,
              right: 0,
              child: Image.asset(
                "assets/Icon.png",
                width: screenWidth * 0.65,
                fit: BoxFit.contain,
              ),
            ),
            // Central Illustration
            Positioned(
              top: screenHeight * 0.067,
              left: -20,
              right: -20,
              child: Image.asset(
                "assets/images_intro/Splash_page_3_image-1.png",
                fit: BoxFit.contain,
                height: screenHeight * 0.7,
              ),
            ),
            // Header (Logo + Skip)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
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
                padding: const EdgeInsets.only(
                    bottom: 36.0, left: 24.0, right: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "Join & Create Communities",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Discover clubs, sports teams, and academic groups or create your own community.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4A68),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Pagination Dots Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dot 0
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9E9EA7).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Dot 1 (Active)
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6139ED),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Dot 2
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => const OnboardingScreenThree(),
                              transition: Transition.rightToLeft,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9E9EA7).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
