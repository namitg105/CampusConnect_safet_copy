import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String senderImageUrl;
  final String message;
  final String messageType; // e.g., 'text', 'image', 'file'
  final Timestamp? sentAt;

  GroupChat({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.senderImageUrl,
    required this.message,
    required this.messageType,
    this.sentAt,
  });

  factory GroupChat.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return GroupChat(
      id: id,
      groupId: map['groupId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImageUrl: map['senderImageUrl'] ?? '',
      message: map['message'] ?? '',
      messageType: map['messageType'] ?? 'text',
      sentAt: map['sentAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'message': message,
      'messageType': messageType,
      'sentAt': sentAt,
    };
  }

  GroupChat copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? message,
    String? messageType,
    Timestamp? sentAt,
  }) {
    return GroupChat(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
