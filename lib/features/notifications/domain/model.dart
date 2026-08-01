import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final Timestamp createdAt;
  final String? type;
  final String? groupId;
  final String? chatId;
  final String? senderId;
  final String? senderName;
  final String? senderEmail;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.type,
    this.groupId,
    this.chatId,
    this.senderId,
    this.senderName,
    this.senderEmail,
    this.isRead = false,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? data['senderName'] ?? data['groupName'] ?? 'Notification',
      description: data['description'] ?? data['message'] ?? data['text'] ?? data['content'] ?? '',
      createdAt: data['createdAt'] ?? data['timestamp'] ?? Timestamp.now(),
      type: data['type'],
      groupId: data['groupId'],
      chatId: data['chatId'],
      senderId: data['senderId'] ?? data['fromUid'],
      senderName: data['senderName'] ?? data['fromName'],
      senderEmail: data['senderEmail'] ?? data['fromEmail'],
      isRead: data['isRead'] ?? data['isSeen'] ?? false,
    );
  }
}
