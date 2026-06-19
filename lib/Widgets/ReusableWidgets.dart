import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constents/AppStyles.dart';
import '../ViewModels/DarkModeViewModels.dart';
import 'ImageWidgets.dart';

class ReusableWidgets extends StatelessWidget {
  final String imagePath;
  final String text;

  ReusableWidgets({
    super.key,
    required this.imagePath,
    required this.text,
  });

  final LightModeController lightModeController = Get.put(LightModeController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
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
                    style: AppStyles.headingTextStyleTwo
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
                  color:lightModeController.isLightMode.value ? Colors.black : Colors.white,
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
