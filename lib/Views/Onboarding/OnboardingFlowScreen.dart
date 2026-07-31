import 'package:flutter/material.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import './components.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final int initialPage;
  const OnboardingFlowScreen({Key? key, this.initialPage = 0})
      : super(key: key);

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPaginationDots(int activeDotIndex, ValueChanged<int> onDotTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = activeDotIndex == index;
        return GestureDetector(
          onTap: () => onDotTap(index),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final splashWidgetComponents =
        Splash_Widget_Components(width: screenWidth, height: screenHeight);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          // Page 0: First Screen ("Get Started")
          _buildSplashScreenContent(splashWidgetComponents),

          // Page 1: Onboarding 1 ("Real-time Conversations")
          _buildOnboardingOneContent(splashWidgetComponents),

          // Page 2: Onboarding 2 ("Join & Create Communities")
          _buildOnboardingTwoContent(screenWidth, screenHeight),

          // Page 3: Onboarding 3 ("Share & Access Resources")
          _buildOnboardingThreeContent(screenWidth, screenHeight),

          // Page 4: Login / Register Screen
          const AuthPage(),
        ],
      ),
    );
  }

  // --- PAGE 0: SPLASH / FIRST SCREEN ---
  Widget _buildSplashScreenContent(Splash_Widget_Components splashComponents) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          const SizedBox.expand(),
          Positioned(
            top: 5,
            left: 10,
            width: 200,
            child: Image.asset("assets/Heading.png"),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/Icon.png",
              width: MediaQuery.of(context).size.width * 0.58,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.12,
            right: 0,
            left: 0,
            child: Image.asset(
              "assets/Splash.png",
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 19.0, vertical: 19.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Connect.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    "Collaborate.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    "Grow Together",
                    style: TextStyle(
                      color: Color(0xFF6139ED),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "The all-in-one student\nCommunication Platform\nfor clubs, courses, and\ncampus communities",
                    style: TextStyle(
                      color: Color(0xFF4A4A68),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _goToPage(1),
                        child: Image.asset(
                          "assets/Button.png",
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _goToPage(4),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Color(0xFF6139ED),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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

  // --- PAGE 1: ONBOARDING SCREEN 1 ---
  Widget _buildOnboardingOneContent(Splash_Widget_Components splashComponents) {
    final height = splashComponents.height;

    // 1. Remove the Scaffold and just return the Stack directly
    return Stack(
      children: [
        // Top Left Graphic
        splashComponents.BackgroundCapDesign(
          true,
          true,
          path: "assets/images_intro/Graduate_hat_right.png",
          height: height * 0.45,
          opacity: 0.01,
          top: 0, // Should now behave normally without bending
          left: 0,
        ),

        // Bottom Right Graphic
        splashComponents.BackgroundCapDesign(
          true,
          true,
          path: "assets/images_intro/Graduate_hat_left.png",
          height: height * 0.45,
          opacity: 0.0,
          bottom: height * 0.065,
          right: 1,
        ),

        // Main Center Content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.025),
            splashComponents.CenterPageDesign(
              path: "assets/images_intro/Splash_page_2_image.png",
            ),
            splashComponents.CenterPageContentDesign(
              contentArray: [
                "Real-time Conversation",
                "Chat discussion and stay updated in organized channels for every topic that matters",
              ],
            ),
            const SizedBox(height: 32),
            _buildPaginationDots(0, (index) => _goToPage(index + 1)),
          ],
        ),

        // 2. Add your Header (Logo & Skip) manually via SafeArea
        // to match exactly what you did in Page 2 and Page 3
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
                  onTap: () => _goToPage(4),
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
      ],
    );
  }

  // --- PAGE 2: ONBOARDING SCREEN 2 ---
  Widget _buildOnboardingTwoContent(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        Positioned(
          top: 436,
          left: 0,
          child: Image.asset(
            "assets/Icon l-r.png",
            width: screenWidth * 0.6,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset(
            "assets/Icon.png",
            width: screenWidth * 0.695,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: screenHeight * 0.11,
          left: -20,
          right: -20,
          child: Image.asset(
            "assets/images_intro/Splash_page_3_image-1.png",
            fit: BoxFit.contain,
            height: screenHeight * 0.7,
          ),
        ),
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
                  onTap: () => _goToPage(4),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 36.0, left: 24.0, right: 24.0),
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
                _buildPaginationDots(1, (index) => _goToPage(index + 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- PAGE 3: ONBOARDING SCREEN 3 ---
  Widget _buildOnboardingThreeContent(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        Positioned(
          top: 1,
          left: 0,
          child: Image.asset(
            "assets/Icon l-r.png",
            width: screenWidth * 0.695,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: screenHeight * 0.46,
          right: 0,
          child: Image.asset(
            "assets/Icon.png",
            width: screenWidth * 0.65,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: screenHeight * 0.067,
          left: -20,
          right: -20,
          child: Image.asset(
            "assets/Gemini_Generated_Image_s38k7zs38k7zs38k 1.png",
            fit: BoxFit.contain,
            height: screenHeight * 0.7,
          ),
        ),
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
                  onTap: () => _goToPage(4),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 50.0,
              left: 20.0,
              right: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/notes 1.png",
                  scale: 20,
                  width: 6000,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Share & Access Resources",
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
                  "Get course notes, important resources,\nand study materials shared by seniors.",
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
                _buildPaginationDots(2, (index) => _goToPage(index + 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
