import 'package:flutter/material.dart';

//-----------------------------//
import './components.dart';

class SplashPageOne extends StatefulWidget {
  const SplashPageOne({Key? key}) : super(key: key);

  @override
  State<SplashPageOne> createState() => _SplashPageOneState();
}

class _SplashPageOneState extends State<SplashPageOne> {
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
            children: [
              _SplashAppWidget.CenterPageDesign(
                path: "assets/images_intro/Splash_page_2_image.png",
              ),
              _SplashAppWidget.CenterPageContentDesign(
                contentArray: [
                  "Real-time Conversations",
                  "Chat dicussion and stay update in organised channel for every topic that matters",
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
  PreferredSizeWidget AppBarDesign() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: width * 0.025,
        children: [
          Image.asset(
            "assets/images_intro/App_icon_1.png",
            width: width * 0.125, //0.085
            alignment: Alignment.centerRight,
          ),
          RichTextDesign(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => {},
          child: Text(
            "Skip",
            style: TextStyle(
              color: Color.fromRGBO(114, 75, 230, 1),
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: width * 0.03),
      ],
    );
  }

  RichText RichTextDesign() {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "uni",
            style: TextStyle(
              color: Color.fromRGBO(114, 75, 230, 1),
              fontSize: width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "Connect",
            style: TextStyle(
              color: Colors.black,
              fontSize: width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget CenterPageDesign() {
    return Image.asset("assets/images_intro/Splash_page_2_image.png");
  }

  Widget CenterPageContentDesign() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Real-time Conversation",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: width * 0.65,
          child: Text(
            "Chat dicussion and stay update in organised channel for every topic that matters",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color.fromARGB(164, 0, 0, 0),
              fontSize: width * 0.04,
            ),
          ),
        ),
      ],
    );
  }

  Widget BackgroundCapDesign(
    bool position,
    bool resize, {
    Alignment? alignmentPosition,
    double? top,
    double? left,
    double? right,
    double? bottom,
    double? width,
    double? height,
    double opacity = 0.0,
    required String path,
  }) {
    if (position) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        height: resize ? height : null,
        width: resize ? width : null,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(opacity),
            BlendMode.hardLight,
          ),
          child: Image.asset(path, width: width, height: height),
        ),
      );
    } else {
      return Container(alignment: alignmentPosition, child: Image.asset(path));
    }
  }
  */

  /*
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBarDesign(),
      body: Stack(
        children: [
          BackgroundCapDesign(
            true,
            true,
            path: "assets/images_intro/Graduate_hat_right.png",
            height: height * 0.35,
            opacity: 0.0,
            top: 0,
            left: 0,
          ),
          BackgroundCapDesign(
            true,
            true,
            path: "assets/images_intro/Graduate_hat_left.png",
            height: height * 0.35,
            opacity: 0.0,
            bottom: height * 0.09,
            right: 0,
          ),
          Column(children: [CenterPageDesign(), CenterPageContentDesign()]),
        ],
      ),
      //Column(children: [CenterPageDesign(), CenterPageContentDesign()]),
      // body: Stack(
      //   children: [
      //     BackgroundCapDesign(
      //       true,
      //       true,
      //       path: "assets/images_intro/Graduate_hat_right.png",
      //       height: height * 0.35,
      //       opacity: 0.3,
      //       top: 0,
      //       left: 0,
      //     ),
      //     BackgroundCapDesign(
      //       true,
      //       true,
      //       path: "assets/images_intro/Graduate_hat_left.png",
      //       height: height * 0.35,
      //       opacity: 0.3,
      //       bottom: height * 0.09,
      //       right: 0,
      //     ),
      //   ],
      // ),
      //
    );
  }

  PreferredSizeWidget AppBarDesign() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: width * 0.025,
        children: [
          Image.asset(
            "assets/images_intro/App_icon_1.png",
            width: width * 0.125, //0.085
            alignment: Alignment.centerRight,
          ),
          RichTextDesign(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => {},
          child: Text(
            "Skip",
            style: TextStyle(
              color: Color.fromRGBO(114, 75, 230, 1),
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: width * 0.03),
      ],
    );
  }

  RichText RichTextDesign() {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "uni",
            style: TextStyle(
              color: Color.fromRGBO(114, 75, 230, 1),
              fontSize: width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "Connect",
            style: TextStyle(
              color: Colors.black,
              fontSize: width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget CenterPageDesign() {
    return Image.asset("assets/images_intro/Splash_page_2_image.png");
  }

  Widget CenterPageContentDesign() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Real-time Conversation",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: width * 0.65,
          child: Text(
            "Chat dicussion and stay update in organised channel for every topic that matters",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color.fromARGB(164, 0, 0, 0),
              fontSize: width * 0.04,
            ),
          ),
        ),
      ],
    );
  }

  Widget BackgroundCapDesign(
    bool position,
    bool resize, {
    Alignment? alignmentPosition,
    double? top,
    double? left,
    double? right,
    double? bottom,
    double? width,
    double? height,
    double opacity = 0.0,
    required String path,
  }) {
    if (position) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        height: resize ? height : null,
        width: resize ? width : null,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(opacity),
            BlendMode.hardLight,
          ),
          child: Image.asset(path, width: width, height: height),
        ),
      );
    } else {
      return Container(alignment: alignmentPosition, child: Image.asset(path));
    }
  }

  */
}
