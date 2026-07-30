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
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid.isNotEmpty) {
        _listen(user.uid);
      } else {
        _cancelSubs();
        unreadCount.value = 0;
      }
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid.isNotEmpty) {
      _listen(currentUser.uid);
    }
  }

  void _cancelSubs() {
    _notifSub?.cancel();
  }

  void _listen(String uid) {
    _cancelSubs();

    // Listen to top-level notifications collection
    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      unreadCount.value = snapshot.docs.length;
    }, onError: (e) {
      print('Top-level unread notification error: $e');
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _cancelSubs();
    super.onClose();
  }
}
