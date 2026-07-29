import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  static Future<void> createNotification({
    required String recipientId,
    required NotificationType type,
    required String title,
    String? subtitle,
    String? description,
    String? targetId,
    Map<String, dynamic>? extraData,
  }) async {
    final senderUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Prevent self-notifications
    if (senderUid == recipientId) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .doc();

    await docRef.set({
      'id': docRef.id,
      'type': type.name,
      'senderId': senderUid,
      'title': title,
      'subtitle': subtitle ?? '',
      'description': description ?? '',
      'targetId': targetId ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      if (extraData != null) ...extraData,
    });
  }

  static Future<void> notifyAllUsers({
    required NotificationType type,
    required String title,
    required String description,
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
            targetId: targetId,
          );
        }
      }
    } catch (e) {
      print('Failed to notify users: $e');
    }
  }
}
