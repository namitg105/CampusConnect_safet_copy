import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

import '../Constents/AppConstents.dart';

class CheckBox extends StatelessWidget {
  CheckBox({
    super.key,
    required this.onPressed,
    required this.isChecked,
  });

  final LightModeController lightModeController = Get.put(LightModeController());

  final VoidCallback onPressed;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isChecked
            ? Icon(Icons.check, color: lightModeController.isLightMode.value ? Colors.black : Colors.white, size: AppConstants.iconSize)
            : null,
      ),
    );
  }
}