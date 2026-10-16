import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';

class LibraryOptionWidget extends StatelessWidget {
  final String iconPath;
  final String label;

  LibraryOptionWidget({super.key, required this.iconPath, required this.label});


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Container(
        height: AppConstants.containerHeight,
        width: AppConstants.containerWidth,
        padding: EdgeInsets.only(left: AppConstants.paddingLeft),
        decoration: BoxDecoration(
          color: context.isLightMode ? AppConstants.darkContainerColor : AppConstants.lightContainerColor,
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
                  context.isLightMode ? Colors.black : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: AppConstants.spacingBetweenIconText),
            Expanded(
              child: Text(
                label,
                style: AppStyles.textStyle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
