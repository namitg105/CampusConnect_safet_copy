import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageEntity {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json, String id) {
    final createdAtValue = json['createdAt'];
    return ChatMessageEntity(
      id: id,
      roomId: json['roomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.tryParse(createdAtValue?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
