import 'package:flutter/material.dart';
import 'reply_preview.dart';
import 'reactions_row.dart';

class ImageMessageBubble extends StatelessWidget {
  final String timestamp;
  final String imageUrl;
  final bool isSender;
  final VoidCallback? onLongPress;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;
  final Map<String, String> reactions;
  final String currentUserId;

  const ImageMessageBubble({
    super.key,
    required this.timestamp,
    required this.imageUrl,
    this.isSender = true,
    this.onLongPress,
    this.repliedMessageContent,
    this.repliedMessageSender,
    this.repliedMessageType,
    this.reactions = const {},
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget replyPreview() {
      if (repliedMessageContent == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ReplyPreview(
          content: repliedMessageContent!,
          sender: repliedMessageSender ?? '',
          messageType: repliedMessageType,
        ),
      );
    }

    final alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;

    final body = imageUrl.isEmpty
        ? Align(
            alignment: alignment,
            child: Container(
              width: screenWidth * 0.55,
              height: 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                  topRight: Radius.zero,
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFF766CF1), Color(0xFF5A48E6)],
                ),
              ),
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(8),
              child: _buildTimestampBadge(),
            ),
          )
        : Align(
            alignment: alignment,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
                topRight: Radius.zero,
              ),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    width: screenWidth * 0.55,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildTimestampBadge(),
                  ),
                ],
              ),
            ),
          );

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            replyPreview(),
            body,
            ReactionsRow(
              reactions: reactions,
              currentUserId: currentUserId,
              isSender: isSender,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        timestamp,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
    );
  }
}
