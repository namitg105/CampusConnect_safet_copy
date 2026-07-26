import 'package:flutter/material.dart';
import 'reply_preview.dart';
import 'reactions_row.dart';

class SenderTextBubble extends StatelessWidget {
  final String message;
  final String timestamp;
  final VoidCallback? onLongPress;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;
  final Map<String, String> reactions;
  final String currentUserId;

  const SenderTextBubble({
    super.key,
    required this.message,
    required this.timestamp,
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
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.70),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                      topRight: Radius.zero,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (repliedMessageContent != null)
                        ReplyPreview(
                          content: repliedMessageContent!,
                          sender: repliedMessageSender ?? '',
                          messageType: repliedMessageType,
                        ),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ReactionsRow(
              reactions: reactions,
              currentUserId: currentUserId,
              isSender: true,
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
