import 'package:flutter/material.dart';

//-----------------------------//
import './components.dart';

class SplashPageTwo extends StatefulWidget {
  const SplashPageTwo({Key? key}) : super(key: key);

  @override
  State<SplashPageTwo> createState() => _SplashPageTwoState();
}

class _SplashPageTwoState extends State<SplashPageTwo> {
  late double width, height;
  late Splash_Widget_Components _SplashAppWidget;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    _SplashAppWidget = Splash_Widget_Components(width: width, height: height);

    return Scaffold(
      appBar: _SplashAppWidget.AppBarDesign(),
      body: Stack(
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
                path:
                    "assets/images_intro/Splash_page_3_image-1.png", //"assets/images_intro/Splash_page_3_image-1.png"
              ),
              _SplashAppWidget.CenterPageContentDesign(
                contentArray: [
                  "Real-time Conversation",
                  "Chat dicussion and stay update in organised channel for every topic that matters",
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
