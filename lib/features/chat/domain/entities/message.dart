import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp createdAt;

  Message({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromMap(
    Map<String, dynamic> map,
  ) {
    return Message(
      senderId: map['senderId'],
      senderName: map['senderName'],
      text: map['text'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
