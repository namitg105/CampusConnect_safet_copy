import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class Onboardingscreen3 extends StatelessWidget {
  Onboardingscreen3({super.key});

  final LightModeController lightModeController =
      Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // Main central illustration layered at the bottom of the Stack

          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/Icon l-r.png",
              width: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 450,
            right: 0,
            child: Image.asset(
              "assets/Icon.png",
              width: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: screenHeight * 0.12,
            left: -20,
            right: -20,
            child: Image.asset(
              "assets/Gemini_Generated_Image_s38k7zs38k7zs38k 1.png",
              fit: BoxFit.contain,
            ),
          ),

          // SafeArea protects the top navigation bar from device notches
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/Heading.png",
                    width: 220,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: const Text(
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

          // Aligns the icon, text, and pagination indicators to the bottom center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 40.0, left: 24.0, right: 24.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Shrinks Column to fit its children
                children: [
                  Image.asset(
                    "assets/notes 1.png",
                    width: 104,
                    height: 97,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Share & Access Resourses",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Get course notes, important resourses,\nand study materials shared by seniors.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A68),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Pagination Dots Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 8,
                        width: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9EA7).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 8,
                        width: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9EA7).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Active Indicator Dot
                      Container(
                        height: 8,
                        width: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6139ED),
                          borderRadius: BorderRadius.circular(4),
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
    );
  }
}
