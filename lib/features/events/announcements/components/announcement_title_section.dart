import 'package:flutter/material.dart';

class AnnouncementTitleSection extends StatelessWidget {
  final int totalCount;
  final int pinnedCount;
  final VoidCallback? onMarkAllRead;

  const AnnouncementTitleSection({
    super.key,
    required this.totalCount,
    required this.pinnedCount,
    this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Announcements',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '$totalCount notices',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF777777),
              ),
            ),
            if (pinnedCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark,
                      size: 14,
                      color: Color(0xFF7A5AF8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$pinnedCount marked',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A5AF8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: onMarkAllRead,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A5AF8),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Color(0xFF7A5AF8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
