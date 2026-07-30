import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Constents/AppConstents.dart';
import '../../ViewModels/NavController.dart';
import '../../ViewModels/NotificationController.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String assetPath;
  final int index;
  final int? badgeCount; // optional badge, not used directly here

  const BottomNavItemWidget({
    Key? key,
    required this.assetPath,
    required this.index,
    this.badgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BottomNavController controller = Get.find();
    final NotificationController notifCtrl = Get.put(NotificationController());
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
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
          if (index == 3 && notifCtrl.unreadCount.value > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
