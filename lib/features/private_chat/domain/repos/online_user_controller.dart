import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/private_chat/data/private-chat-functions/user_online_function.dart';

class UserOnlineController extends GetxController {
  final Map<String, dynamic> targetUser;
  late final UserOnlineFunction _onlineService;

  var isOnline = false.obs;
  var isloading = false.obs;

  StreamSubscription? _statusSubscription;

  UserOnlineController({required this.targetUser});

  @override
  void onInit() {
    super.onInit();
    _onlineService = UserOnlineFunction(target_user: targetUser);
    _listenToUserStatus();
  }

  @override
  void onClose() {
    _statusSubscription?.cancel();
    super.onClose();
  }

  void _listenToUserStatus() {
    isloading.value = true;

    _statusSubscription = _onlineService.getUserOnline().listen(
        (DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data();
        isOnline.value = data?['isOnline'] ?? false;
        isloading.value = false;
      }
    }, onError: (error) {
      print("Error in UserOnlineController: $error");
      isloading.value = false;
    });
  }
}
