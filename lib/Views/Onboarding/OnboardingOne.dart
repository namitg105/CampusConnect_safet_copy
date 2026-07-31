import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'OnbordingTwo.dart';
import 'OnboardingThree.dart';

//-----------------------------//
import './components.dart';

class Onboardingone extends StatefulWidget {
  const Onboardingone({Key? key}) : super(key: key);

  @override
  State<Onboardingone> createState() => _OnboardingoneState();
}

class _OnboardingoneState extends State<Onboardingone> {
  late double width, height;
  late Splash_Widget_Components _SplashAppWidget;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    _SplashAppWidget = Splash_Widget_Components(width: width, height: height);

    return Scaffold(
      appBar: _SplashAppWidget.AppBarDesign(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swiped Left -> Go to OnboardingScreenTwo
            Get.to(
              () => const OnboardingScreenTwo(),
              transition: Transition.rightToLeft,
            );
          }
        },
        child: Stack(
          children: [
            _SplashAppWidget.BackgroundCapDesign(
              true,
              true,
              path: "assets/images_intro/Graduate_hat_right.png",
              height: height * 0.35,
              opacity: 0.01,
              top: 0,
              left: 0,
            ),
            _SplashAppWidget.BackgroundCapDesign(
              true,
              true,
              path: "assets/images_intro/Graduate_hat_left.png",
              height: height * 0.35,
              opacity: 0.0,
              bottom: height * 0.09,
              right: 0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.025),
                _SplashAppWidget.CenterPageDesign(
                  path: "assets/images_intro/Splash_page_2_image.png",
                ),
                _SplashAppWidget.CenterPageContentDesign(
                  contentArray: [
                    "Real-time Conversation",
                    "Chat dicussion and stay update in organised channel for every topic that matters",
                  ],
                ),
                const SizedBox(height: 32),
                // 3 Pagination Dots Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dot 0 (Active)
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
                    // Dot 1 -> Navigate to OnboardingScreenTwo
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const OnboardingScreenTwo(),
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
                    // Dot 2 -> Navigate to OnboardingScreenThree
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
          ],
        ),
      ),
    );
  }
}
