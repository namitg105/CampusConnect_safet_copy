enum MessageType { text, image, video, doc }

/// One message in a 1-to-1 chat room. Pure Dart: Firestore mapping lives
/// in `ChatMessageModel`.
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

  /// uid -> emoji
  final Map<String, String> reactions;

  const ChatMessage({
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
}
