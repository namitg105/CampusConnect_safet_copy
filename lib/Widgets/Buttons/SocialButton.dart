import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String asset;
  final VoidCallback? onPressed;

  SocialButton({
    super.key,
    required this.text,
    required this.asset,
    this.onPressed,
  });

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Image.asset(asset, height: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: lightModeController.isLightMode.value ? Colors.white : Colors.black,
          minimumSize: const Size(180, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
