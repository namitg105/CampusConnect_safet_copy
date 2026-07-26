import 'package:cloud_firestore/cloud_firestore.dart';

class PinnedMessage {
  final DateTime pinnedMessageTimestamp;
  final String pinnedMessageId;
  final String pinnedMessageContent;
  final String pinnedBy;

  PinnedMessage({
    required this.pinnedMessageTimestamp,
    required this.pinnedMessageId,
    required this.pinnedMessageContent,
    required this.pinnedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'pinned_message_timestamp': FieldValue.serverTimestamp(),
      'pinned_message_id': pinnedMessageId,
      'pinned_message_content': pinnedMessageContent,
      'pinned_by': pinnedBy,
    };
  }

  factory PinnedMessage.fromJson(Map<String, dynamic> json) {
    return PinnedMessage(
      pinnedMessageTimestamp:
          (json['pinned_message_timestamp'] as dynamic)?.toDate() ??
              DateTime.now(),
      pinnedMessageId: json['pinned_message_id'] ?? '',
      pinnedMessageContent: json['pinned_message_content'] ?? '',
      pinnedBy: json['pinned_by'] ?? '',
    );
  }
}
