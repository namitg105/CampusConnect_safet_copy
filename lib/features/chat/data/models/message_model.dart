import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../security/aes_service.dart';
import '../../domain/entities/message.dart';

/// Firestore mapping for `chats/{groupId}/messages/{messageId}`.
/// `text` and `mediaUrl` are stored AES-encrypted (base64).
///
/// ```json
/// {
///   "senderId": "uid1", "senderName": "Namit", "senderImage": "https://...",
///   "text": "<base64>", "type": "text", "mediaUrl": null,
///   "createdAt": <Timestamp>, "reactions": {"uid2": "👍"}
/// }
/// ```
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.type,
    super.mediaUrl,
    super.senderImage,
    required super.createdAt,
    super.reactions,
  });

  /// Older messages may be plain text: fall back to the raw value.
  static String _decryptOrRaw(AESService aes, String value) {
    try {
      return aes.decrypt(value);
    } catch (_) {
      return value;
    }
  }

  factory MessageModel.fromMap(
    String id,
    Map<String, dynamic> map,
    AESService aes,
  ) {
    final rawMedia = map['mediaUrl'] as String?;
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      text: _decryptOrRaw(aes, map['text'] ?? ''),
      type: map['type'] ?? 'text',
      mediaUrl: rawMedia == null ? null : _decryptOrRaw(aes, rawMedia),
      createdAt:
          ((map['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
      reactions: map['reactions'] != null
          ? Map<String, dynamic>.from(map['reactions'])
          : null,
    );
  }

  static Map<String, dynamic> toMap(Message message, AESService aes) {
    return {
      'senderId': message.senderId,
      'senderName': message.senderName,
      'senderImage': message.senderImage,
      'text': aes.encrypt(message.text),
      'type': message.type,
      'mediaUrl':
          message.mediaUrl == null ? null : aes.encrypt(message.mediaUrl!),
      'createdAt': Timestamp.fromDate(message.createdAt),
      'reactions': message.reactions,
    };
  }
}
