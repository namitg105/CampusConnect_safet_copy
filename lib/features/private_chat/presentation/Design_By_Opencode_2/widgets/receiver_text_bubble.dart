import 'package:flutter/material.dart';
import 'reply_preview.dart';
import 'reactions_row.dart';

class ReceiverTextBubble extends StatelessWidget {
  final String message;
  final String timestamp;
  final VoidCallback? onLongPress;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;
  final Map<String, String> reactions;
  final String currentUserId;

  const ReceiverTextBubble({
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.70),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF766CF1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(32),
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                      topLeft: Radius.zero,
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
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
              isSender: false,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
