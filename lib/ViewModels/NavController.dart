import 'package:get/get.dart';
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
        Get.to(FeedScreen());
        break;
      case 1:
        Get.to(SearchScreen());
        break;
      case 2:
        Get.to(AddUsers());
        break;
      case 3:
        Get.to(NotificationScreen());
        break;
      case 4:
        Get.to(ProfileScreen());
        break;
    }
  }
}
