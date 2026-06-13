import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';

class LibraryOptionWidget extends StatelessWidget {
  final String iconPath;
  final String label;

  LibraryOptionWidget({super.key, required this.iconPath, required this.label});

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Container(
        height: AppConstants.containerHeight,
        width: AppConstants.containerWidth,
        padding: EdgeInsets.only(left: AppConstants.paddingLeft),
        decoration: BoxDecoration(
          color: lightModeController.isLightMode.value ? AppConstants.darkContainerColor : AppConstants.lightContainerColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppConstants.iconSizes,
              height: AppConstants.iconSizes,
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  lightModeController.isLightMode.value ? Colors.black : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: AppConstants.spacingBetweenIconText),
            Expanded(
              child: Text(
                label,
                style: AppStyles.textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
