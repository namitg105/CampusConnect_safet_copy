import 'package:flutter/material.dart';

class AnnouncementFooter extends StatelessWidget {
  final String department;
  final String readTime;
  final VoidCallback? onBookmark;
  final VoidCallback? onOpen;

  const AnnouncementFooter({
    super.key,
    required this.department,
    required this.readTime,
    this.onBookmark,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$department  ·  $readTime',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0B0B0),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onBookmark,
          child: const Icon(
            Icons.bookmark_border,
            color: Color(0xFF7A5AF8),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onOpen,
          child: const Icon(
            Icons.open_in_new,
            color: Color(0xFF7A5AF8),
            size: 20,
          ),
        ),
      ],
    );
  }
}
