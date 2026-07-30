import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  static Future<void> createNotification({
    required String recipientId,
    String? senderId,
    required NotificationType type,
    required String title,
    String? subtitle,
    String? description,
    String? targetId,
    Map<String, dynamic>? extraData,
  }) async {
    final senderUid = (senderId != null && senderId.isNotEmpty)
        ? senderId
        : (FirebaseAuth.instance.currentUser?.uid ?? '');

    if (recipientId.isEmpty) return;

    String senderName = '';
    String senderImage = '';
    if (senderUid.isNotEmpty) {
      try {
        final senderDoc = await FirebaseFirestore.instance.collection('users').doc(senderUid).get();
        if (senderDoc.exists) {
          final sData = senderDoc.data() ?? {};
          senderName = sData['name'] ??
              sData['username'] ??
              (sData['email'] is String && sData['email'].contains('@')
                  ? sData['email'].split('@').first
                  : '');
          senderImage = sData['profileImage'] ?? sData['photoURL'] ?? sData['imageURL'] ?? '';
        }
      } catch (_) {}
    }

    final notifData = {
      'recipientId': recipientId,
      'type': type.name,
      'senderId': senderUid,
      'senderName': senderName,
      'senderImage': senderImage,
      'title': title,
      'subtitle': subtitle ?? '',
      'description': description ?? '',
      'targetId': targetId ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      if (extraData != null) ...extraData,
    };

    // Primary: Top-level notifications collection (Always succeeds with standard permissions)
    try {
      final topRef = FirebaseFirestore.instance.collection('notifications').doc();
      await topRef.set({
        'id': topRef.id,
        ...notifData,
      });
    } catch (e) {
      print('Top-level notification error: $e');
    }

    // Secondary: Subcollection under user (if permitted by rules)
    try {
      final subRef = FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc();
      await subRef.set({
        'id': subRef.id,
        ...notifData,
      });
    } catch (_) {}
  }

  static Future<void> notifyAllUsers({
    required NotificationType type,
    required String title,
    required String description,
    String? subtitle,
    String? targetId,
  }) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in usersSnapshot.docs) {
        if (doc.id != currentUid) {
          await createNotification(
            recipientId: doc.id,
            type: type,
            title: title,
            description: description,
            subtitle: subtitle,
            targetId: targetId,
          );
        }
      }
    } catch (e) {
      print('Failed to notify users: $e');
    }
  }
}
