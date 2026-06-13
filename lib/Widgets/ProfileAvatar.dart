import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import '../Constents/AppConstents.dart'; // Fixed incorrect import

class ProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double? radius;
  final VoidCallback? onCameraTap;

  ProfileAvatar({
    super.key,
    required this.imagePath,
    this.radius,
    this.onCameraTap,
  });

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    bool isFileImage = imagePath.trim().isNotEmpty && File(imagePath).existsSync();

    return GestureDetector(
      onTap: onCameraTap,
      child: CircleAvatar(
        backgroundColor: lightModeController.isLightMode.value? Colors.black : Colors.grey,
        radius: radius ?? 55.0,
        backgroundImage: isFileImage
            ? FileImage(File(imagePath))
            : AssetImage(AppConstants.defaultProfileImage, ) as ImageProvider,
      ),
    );
  }
}
