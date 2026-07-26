import 'package:flutter/material.dart';

class ReactionsRow extends StatelessWidget {
  final Map<String, String> reactions;
  final String currentUserId;
  final bool isSender;

  const ReactionsRow({
    super.key,
    required this.reactions,
    required this.currentUserId,
    this.isSender = false,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final grouped = <String, int>{};
    for (final emoji in reactions.values) {
      grouped[emoji] = (grouped[emoji] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Wrap(
          spacing: -4,
          children: grouped.entries.map((entry) {
            final count = entry.value;
            final userReacted = reactions.values
                .where((e) => e == entry.key)
                .length;
            final showCount = count > 1;

            return Container(
              height: 28,
              constraints: const BoxConstraints(minWidth: 28),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                  if (showCount)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
