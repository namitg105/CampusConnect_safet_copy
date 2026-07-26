enum MessageType { text, image, video, doc }

class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool read;
  final MessageType type;
  final String? imageUrl;
  final String? docUrl;
  final String? repliedMessageId;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;
  final Map<String, String> reactions;

  ChatMessage({
    this.messageId = '',
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.read = false,
    this.type = MessageType.text,
    this.imageUrl,
    this.docUrl,
    this.repliedMessageId,
    this.repliedMessageContent,
    this.repliedMessageSender,
    this.repliedMessageType,
    this.reactions = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'read': read,
      'type': type.name,
      'imageUrl': imageUrl,
      'docUrl': docUrl,
      'repliedMessageId': repliedMessageId,
      'repliedMessageContent': repliedMessageContent,
      'repliedMessageSender': repliedMessageSender,
      'repliedMessageType': repliedMessageType,
      'reactions': reactions,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, String docId) {
    MessageType parsedType = MessageType.text;
    if (json['type'] != null) {
      parsedType = MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      );
    }

    return ChatMessage(
      messageId: docId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: (json['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      read: json['read'] ?? false,
      type: parsedType,
      imageUrl: json['imageUrl'],
      docUrl: json['docUrl'],
      repliedMessageId: json['repliedMessageId'],
      repliedMessageContent: json['repliedMessageContent'],
      repliedMessageSender: json['repliedMessageSender'],
      repliedMessageType: json['repliedMessageType'],
      reactions: json['reactions'] != null
          ? Map<String, String>.from(json['reactions'] as Map)
          : <String, String>{},
    );
  }
}
