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

    // Listen to notifications collection for real-time unread count
    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .snapshots()
        .listen((snapshot) {
      final user = FirebaseAuth.instance.currentUser;
      final currentUid = user?.uid ?? '';
      final userEmail = user?.email?.toLowerCase().trim() ?? '';
      final userDomain = userEmail.contains('@') ? userEmail.split('@').last : '';

      final count = snapshot.docs.where((doc) {
        final data = doc.data();
        final isRead = (data['isRead'] == true) || (data['isSeen'] == true);
        if (isRead) return false;

        final recipientId = data['recipientId'] as String?;
        if (recipientId != null && recipientId.isNotEmpty && recipientId != currentUid) {
          return false;
        }

        final senderEmail = (data['senderEmail'] as String?)?.toLowerCase().trim();
        if (userDomain.isNotEmpty && senderEmail != null && senderEmail.contains('@')) {
          final senderDomain = senderEmail.split('@').last.toLowerCase().trim();
          return senderDomain == userDomain;
        }
        return true;
      }).length;

      unreadCount.value = count;
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
