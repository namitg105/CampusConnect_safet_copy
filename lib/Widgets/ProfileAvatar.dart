import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import '../Constents/AppConstents.dart'; // Fixed incorrect import

class ProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double? radius;
  final VoidCallback? onCameraTap;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.radius,
    this.onCameraTap,
  });


  @override
  Widget build(BuildContext context) {
    bool isFileImage = imagePath.trim().isNotEmpty && File(imagePath).existsSync();

    return GestureDetector(
      onTap: onCameraTap,
      child: CircleAvatar(
        backgroundColor: context.isLightMode? Colors.black : Colors.grey,
        radius: radius ?? 55.0,
        backgroundImage: isFileImage
            ? FileImage(File(imagePath))
            : AssetImage(AppConstants.defaultProfileImage, ) as ImageProvider,
      ),
    );
  }
}
