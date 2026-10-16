/// One message in a community chat. Pure Dart: encryption and Firestore
/// mapping live in `MessageModel` (data layer).
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String type; // 'text' | 'image' | 'video' | 'document'
  final String? mediaUrl;
  final String? senderImage;
  final DateTime createdAt;
  final Map<String, dynamic>? reactions;

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

  DateTime get timestamp => createdAt;

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
}
