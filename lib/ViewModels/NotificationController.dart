import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationController extends GetxController {
  RxInt unreadCount = 0.obs;
  StreamSubscription? _notifSub;
  StreamSubscription? _authSub;

  @override
  void onInit() {
    super.onInit();
    _listenAuth();
  }

  void _listenAuth() {
    // Listen to Auth State so that when user logs in or switches, the stream updates immediately
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid.isNotEmpty) {
        _listen(user.uid);
      } else {
        _notifSub?.cancel();
        unreadCount.value = 0;
      }
    });

    // Also check current user immediately in case already logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid.isNotEmpty) {
      _listen(currentUser.uid);
    }
  }

  void _listen(String uid) {
    _notifSub?.cancel();
    _notifSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      unreadCount.value = snapshot.docs.length;
    }, onError: (e) {
      print('Failed to listen to unread notifications: $e');
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _notifSub?.cancel();
    super.onClose();
  }
}
