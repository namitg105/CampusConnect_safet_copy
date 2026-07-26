import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/di/injection.dart';
import '../../../security/aes_service.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String type;
  final String? mediaUrl;
  final String? senderImage;
  final Timestamp createdAt;
  final Map<String, dynamic>? reactions; // Added reactions field

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    this.mediaUrl,
    this.senderImage,
    required this.createdAt,
    this.reactions,
  });

  DateTime get timestamp => createdAt.toDate();

  factory Message.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final aes = sl<AESService>();

    String decryptedText = "";
    String? decryptedMedia;

    try {
      decryptedText = aes.decrypt(data['text'] ?? "");
    } catch (_) {
      decryptedText = data['text'] ?? "";
    }

    if (data['mediaUrl'] != null) {
      try {
        decryptedMedia = aes.decrypt(data['mediaUrl']);
      } catch (_) {
        decryptedMedia = data['mediaUrl'];
      }
    }
    print("Message senderImage: ${data['senderImage']}");
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImage: data['senderImage'] ?? '',
      text: decryptedText,
      type: data['type'] ?? 'text',
      mediaUrl: decryptedMedia,
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
      reactions: data['reactions'] != null
          ? Map<String, dynamic>.from(data['reactions'])
          : null,
    );
  }

  factory Message.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final aes = sl<AESService>();

    String decryptedText = "";
    String? decryptedMedia;

    try {
      decryptedText = aes.decrypt(map['text'] ?? "");
    } catch (_) {
      decryptedText = map['text'] ?? "";
    }

    if (map['mediaUrl'] != null) {
      try {
        decryptedMedia = aes.decrypt(map['mediaUrl']);
      } catch (_) {
        decryptedMedia = map['mediaUrl'];
      }
    }

    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      text: decryptedText,
      type: map['type'] ?? 'text',
      mediaUrl: decryptedMedia,
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      reactions: map['reactions'] != null
          ? Map<String, dynamic>.from(map['reactions'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final aes = sl<AESService>();

    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'text': aes.encrypt(text),
      'type': type,
      'mediaUrl': mediaUrl == null ? null : aes.encrypt(mediaUrl!),
      'createdAt': createdAt,
      'reactions': reactions,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? text,
    String? type,
    String? mediaUrl,
    Timestamp? createdAt,
    Map<String, dynamic>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
    );
  }

  bool get isText => type == "text";
  bool get isImage => type == "image";
  bool get isVideo => type == "video";
}
