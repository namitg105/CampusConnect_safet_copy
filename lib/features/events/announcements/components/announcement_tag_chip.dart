import 'package:flutter/material.dart';
import '../models/announcement_model.dart';

class AnnouncementTagChip extends StatelessWidget {
  final String label;
  final AnnouncementPriority? priority;

  const AnnouncementTagChip({
    super.key,
    required this.label,
    this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.$2,
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    final lower = label.toLowerCase();
    if (lower == 'critical') {
      return (const Color(0xFFFDECEC), const Color(0xFFF04438));
    }
    if (lower == 'urgent') {
      return (const Color(0xFFEEE8FF), const Color(0xFF7A5AF8));
    }
    if (lower == 'high') {
      return (const Color(0xFFEEE8FF), const Color(0xFF7A5AF8));
    }
    if (lower == 'pinned') {
      return (const Color(0xFFFFF4E4), const Color(0xFFF59E0B));
    }
    if (lower == 'featured') {
      return (const Color(0xFFFDECEC), const Color(0xFFF04438));
    }
    if (lower == 'scheduled') {
      return (const Color(0xFFF3F4F6), const Color(0xFF777777));
    }
    if (lower == 'club') {
      return (const Color(0xFFEEE8FF), const Color(0xFF7A5AF8));
    }
    if (lower == 'events') {
      return (const Color(0xFFFFF4E4), const Color(0xFFF59E0B));
    }
    return (const Color(0xFFF3F4F6), const Color(0xFF777777));
  }
}
