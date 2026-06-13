import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Constents/AppConstents.dart';
import '../../ViewModels/NavController.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String assetPath;
  final int index;

  const BottomNavItemWidget({Key? key, required this.assetPath, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BottomNavController controller = Get.find();
    return Obx(
          () => SvgPicture.asset(
        assetPath,
        height: 32,
        width: 32,
        colorFilter: ColorFilter.mode(
          controller.selectedIndex.value == index
              ? AppConstants.dotActiveColor
              : AppConstants.navColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
