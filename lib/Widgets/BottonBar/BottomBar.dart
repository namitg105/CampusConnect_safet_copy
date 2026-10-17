import 'package:flutter/material.dart';
import 'package:noteswap/core/navigation/app_navigator.dart';
import '../../Constents/AppConstents.dart';
import '../../Views/AddUsers.dart';
import '../../Views/FeedScreen.dart';
import '../../Views/Notification.dart';
import '../../Views/ProfileScreen.dart';
import '../../Views/SearchScreen.dart';
import 'BottomNavitemWidget.dart';
import '../ImageWidgets.dart';

/// Bottom bar of the legacy NoteSwap screens.
///
/// [currentIndex] is the tab of the screen that shows this bar. (The old
/// GetX controller remembered the last tapped tab instead, which was wrong
/// after pressing back.)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  static void _open(int index) {
    switch (index) {
      case 0:
        AppNavigator.push(FeedScreen());
      case 1:
        AppNavigator.push(SearchScreen());
      case 2:
        AppNavigator.push(const AddUsers());
      case 3:
        AppNavigator.push(NotificationScreen());
      case 4:
        AppNavigator.push(const ProfileScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: _open,
      items: [
        BottomNavigationBarItem(
          icon: BottomNavItemWidget(
              assetPath: 'assets/home3.svg', isSelected: currentIndex == 0),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: BottomNavItemWidget(
              assetPath: 'assets/Vector.svg', isSelected: currentIndex == 1),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () => _open(2),
            child: ImageWidget(imagePath: AppConstants.addIcon),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: BottomNavItemWidget(
            assetPath: 'assets/notification.svg',
            isSelected: currentIndex == 3,
            showUnreadDot: true,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: BottomNavItemWidget(
              assetPath: 'assets/Vector2.svg', isSelected: currentIndex == 4),
          label: '',
        ),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
