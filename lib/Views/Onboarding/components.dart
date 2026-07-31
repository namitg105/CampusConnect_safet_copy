import 'package:flutter/material.dart';

class Splash_Widget_Components {
  const Splash_Widget_Components({required this.width, required this.height});

  final double width;
  final double height;

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

  Widget CenterPageDesign({required String path}) {
    return Container(child: Image.asset(path));
  }

  Widget CenterPageContentDesign({required List<String> contentArray}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          contentArray[0],
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
            contentArray[1],
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
}
