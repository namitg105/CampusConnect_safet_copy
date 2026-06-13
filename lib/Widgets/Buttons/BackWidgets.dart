import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const BackWidget({
    super.key,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(imagePath),
      onPressed: onTap,
    );
  }
}
