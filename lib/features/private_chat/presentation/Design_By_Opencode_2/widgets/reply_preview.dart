import 'package:flutter/material.dart';

class ReplyPreview extends StatelessWidget {
  final String sender;
  final String content;
  final String? messageType;

  const ReplyPreview({
    super.key,
    required this.sender,
    required this.content,
    this.messageType,
  });

  String get _displayContent {
    if (content.isNotEmpty) return content;
    switch (messageType) {
      case 'image':
        return 'Photo';
      case 'doc':
      case 'video':
        return 'File';
      default:
        return 'Message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 8),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: const Color(0xFF7447FF).withOpacity(0.6), width: 3),
        ),
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sender,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7447FF),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _displayContent,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
