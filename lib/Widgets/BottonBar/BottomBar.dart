import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ViewModels/NavController.dart';
import '../../Constents/AppConstents.dart';
import 'BottomNavitemWidget.dart';
import '../ImageWidgets.dart';

class BottomNavBar extends StatelessWidget {
  final BottomNavController controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.selectedIndex.value,
        onTap: (index) => controller.changeIndex(index),
        items: [
          BottomNavigationBarItem(
            icon: BottomNavItemWidget(assetPath: 'assets/home3.svg', index: 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: BottomNavItemWidget(
                assetPath: 'assets/Vector.svg', index: 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => controller.changeIndex(2),
              child: ImageWidget(imagePath: AppConstants.addIcon),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                BottomNavItemWidget(assetPath: 'assets/notification.svg', index: 3),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                BottomNavItemWidget(assetPath: 'assets/Vector2.svg', index: 4),
            label: '',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
