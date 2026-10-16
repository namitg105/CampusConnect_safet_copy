import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/pinned_message.dart';

DateTime? _toDate(dynamic value) =>
    value is Timestamp ? value.toDate() : (value is DateTime ? value : null);

/// `chat_rooms/{roomId}/messages/{messageId}`
///
/// ```json
/// {
///   "senderId": "a", "receiverId": "b", "message": "hi", "read": false,
///   "timestamp": <server timestamp>, "type": "text|image|doc|video",
///   "imageUrl": null, "docUrl": null, "reactions": {"b": "❤️"},
///   "repliedMessageId": null, "repliedMessageContent": null,
///   "repliedMessageSender": null, "repliedMessageType": null
/// }
/// ```
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    super.messageId,
    required super.senderId,
    required super.receiverId,
    required super.message,
    required super.timestamp,
    super.read,
    super.type,
    super.imageUrl,
    super.docUrl,
    super.repliedMessageId,
    super.repliedMessageContent,
    super.repliedMessageSender,
    super.repliedMessageType,
    super.reactions,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String docId) {
    return ChatMessageModel(
      messageId: docId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      // A message written moments ago has no server timestamp yet.
      timestamp: _toDate(json['timestamp']) ?? DateTime.now(),
      read: json['read'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      imageUrl: json['imageUrl'],
      docUrl: json['docUrl'],
      repliedMessageId: json['repliedMessageId'],
      repliedMessageContent: json['repliedMessageContent'],
      repliedMessageSender: json['repliedMessageSender'],
      repliedMessageType: json['repliedMessageType'],
      reactions: json['reactions'] != null
          ? Map<String, String>.from(json['reactions'] as Map)
          : const <String, String>{},
    );
  }
}

/// `chat_rooms/{roomId}/pinned_message/current_pinned`
class PinnedMessageModel extends PinnedMessage {
  const PinnedMessageModel({
    required super.pinnedMessageTimestamp,
    required super.pinnedMessageId,
    required super.pinnedMessageContent,
    required super.pinnedBy,
  });

  factory PinnedMessageModel.fromJson(Map<String, dynamic> json) {
    return PinnedMessageModel(
      pinnedMessageTimestamp:
          _toDate(json['pinned_message_timestamp']) ?? DateTime.now(),
      pinnedMessageId: json['pinned_message_id'] ?? '',
      pinnedMessageContent: json['pinned_message_content'] ?? '',
      pinnedBy: json['pinned_by'] ?? '',
    );
  }

  static Map<String, dynamic> toJson({
    required String messageId,
    required String content,
    required String pinnedBy,
  }) {
    return {
      'pinned_message_timestamp': FieldValue.serverTimestamp(),
      'pinned_message_id': messageId,
      'pinned_message_content': content,
      'pinned_by': pinnedBy,
    };
  }
}

/// `chat_rooms/{roomId}`: participants, lastMessage, lastMessageTimestamp,
/// createdAt and one `unreadCount_{uid}` counter per participant.
class ChatRoomModel extends ChatRoomSummary {
  const ChatRoomModel({
    required super.id,
    required super.participants,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCounts,
  });

  factory ChatRoomModel.fromJson(String id, Map<String, dynamic> json) {
    final unread = <String, int>{};
    json.forEach((key, value) {
      if (key.startsWith('unreadCount_') && value is num) {
        unread[key.substring('unreadCount_'.length)] = value.toInt();
      }
    });
    return ChatRoomModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? const []),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: _toDate(json['lastMessageTimestamp']),
      unreadCounts: unread,
    );
  }
}

/// `users/{uid}/friend_requests/{otherUid}`
class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.fromUid,
    required super.fromName,
    required super.fromEmail,
    required super.fromImageURL,
    required super.status,
    required super.timestamp,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> data) {
    return FriendRequestModel(
      fromUid: data['fromUid'] ?? '',
      fromName: data['fromName'] ?? '',
      fromEmail: data['fromEmail'] ?? '',
      fromImageURL: data['fromImageURL'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: _toDate(data['timestamp']) ?? DateTime.now(),
    );
  }
}
