import 'package:flutter/material.dart';
import 'reply_preview.dart';
import 'reactions_row.dart';

class FileMessageCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String timestamp;
  final bool isSender;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;
  final Map<String, String> reactions;
  final String currentUserId;

  const FileMessageCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.timestamp,
    this.isSender = false,
    this.onTap,
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
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (repliedMessageContent != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ReplyPreview(
                  content: repliedMessageContent!,
                  sender: repliedMessageSender ?? '',
                  messageType: repliedMessageType,
                ),
              ),
            Align(
              alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: screenWidth * 0.60,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSender
                      ? Colors.white
                      : const Color(0xFF5C46E2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                    topRight: Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSender
                            ? const Color(0xFF5C46E2).withValues(alpha: 0.1)
                            : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description,
                        color: isSender
                            ? const Color(0xFF5C46E2)
                            : Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSender
                                  ? const Color(0xFF333333)
                                  : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileSize.isNotEmpty ? fileSize : 'File',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSender
                                  ? Colors.grey
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSender
                            ? const Color(0xFF5C46E2)
                            : const Color(0xFF766CF1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ReactionsRow(
              reactions: reactions,
              currentUserId: currentUserId,
              isSender: isSender,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isSender ? 0 : 4,
                right: isSender ? 4 : 0,
              ),
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
