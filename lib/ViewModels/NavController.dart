import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:get/get.dart' hide SnackPosition;
import 'package:noteswap/Views/AddUsers.dart';

import '../Views/FeedScreen.dart';
import '../Views/Notification.dart';
import '../Views/ProfileScreen.dart';
import '../Views/SearchScreen.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        AppNavigator.push(FeedScreen());
        break;
      case 1:
        AppNavigator.push(SearchScreen());
        break;
      case 2:
        AppNavigator.push(AddUsers());
        break;
      case 3:
        AppNavigator.push(NotificationScreen());
        break;
      case 4:
        AppNavigator.push(ProfileScreen());
        break;
    }
  }
}
