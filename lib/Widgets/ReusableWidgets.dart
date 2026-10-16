import 'package:flutter/material.dart';
import '../Constents/AppStyles.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import 'ImageWidgets.dart';

class ReusableWidgets extends StatelessWidget {
  final String imagePath;
  final String text;

  ReusableWidgets({
    super.key,
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.isLightMode ? Colors.white : Colors.black,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppStyles.headingTextStyleTwo(context)
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 570,
                decoration: BoxDecoration(
                  color:context.isLightMode ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ImageWidget(
                        imagePath: imagePath,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
