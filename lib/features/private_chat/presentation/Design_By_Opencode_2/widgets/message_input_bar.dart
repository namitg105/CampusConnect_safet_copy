import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final ChatMessage? replyMessage;
  final VoidCallback? onCancelReply;

  const MessageInputBar({
    super.key,
    this.controller,
    this.onSend,
    this.onAttach,
    this.replyMessage,
    this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyMessage != null) _buildReplyPreview(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onAttach,
                        icon: const Icon(
                          Icons.attach_file,
                          color: Color(0xFF5A48E6),
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ok. Let me check',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF999999),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onSend,
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF5A48E6),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyPreview() {
    final msg = replyMessage!;
    final previewText = msg.text.isNotEmpty
        ? msg.text
        : msg.type == ChatMessageType.image
            ? 'Photo'
            : 'File';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 4),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6FB),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5A48E6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.isSender ? 'You' : 'Contact',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A48E6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  previewText,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF8D8D8D)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancelReply,
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF8D8D8D)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
