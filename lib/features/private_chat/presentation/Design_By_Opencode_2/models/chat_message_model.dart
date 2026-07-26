enum ChatMessageType { text, image, file, dateSeparator }

class ChatMessage {
  final ChatMessageType type;
  final bool isSender;
  final String text;
  final String timestamp;
  final String? imageUrl;
  final String? fileName;
  final String? fileSize;
  final String? dateLabel;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;

  const ChatMessage({
    required this.type,
    this.isSender = false,
    this.text = '',
    this.timestamp = '',
    this.imageUrl = '',
    this.fileName,
    this.fileSize,
    this.dateLabel,
    this.repliedMessageContent,
    this.repliedMessageSender,
    this.repliedMessageType,
  });
}
