import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

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


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Image.asset(asset, height: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.isLightMode ? Colors.white : Colors.black,
          minimumSize: const Size(180, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
