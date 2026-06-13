import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Constents/AppConstents.dart';
import '../../ViewModels/NavController.dart';

class SvgImageWidgets extends StatelessWidget {
  final String assetPath;
  final int index;

  const SvgImageWidgets(
      {Key? key, required this.assetPath, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BottomNavController controller = Get.find();

    return Obx(
      () => SizedBox(
        // height: 32, // Ensure consistent height
        // width: 32, // Ensure consistent width
        child: FittedBox(
          fit: BoxFit.contain,
          child: SvgPicture.asset(
            assetPath,
            colorFilter: ColorFilter.mode(
              controller.selectedIndex.value == index
                  ? AppConstants.dotActiveColor
                  : AppConstants.navColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
