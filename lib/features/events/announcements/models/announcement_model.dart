import 'package:flutter/material.dart';

enum AnnouncementCategory {
  university,
  club,
  events,
}

enum AnnouncementPriority {
  critical,
  urgent,
  high,
  pinned,
  scheduled,
  normal,
}

class AnnouncementData {
  final String id;
  final AnnouncementCategory category;
  final AnnouncementPriority priority;
  final String title;
  final String description;
  final List<String> tags;
  final DateTime timestamp;
  final String department;
  final String readTime;
  final bool isRead;
  final bool isFeatured;

  const AnnouncementData({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.tags,
    required this.timestamp,
    required this.department,
    required this.readTime,
    this.isRead = false,
    this.isFeatured = false,
  });

  bool get isPinned => priority == AnnouncementPriority.pinned;

  Color get accentColor {
    if (isFeatured) return const Color(0xFFF04438);
    return const Color(0xFF7A5AF8);
  }

  AnnouncementData copyWith({
    String? id,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? timestamp,
    String? department,
    String? readTime,
    bool? isRead,
    bool? isFeatured,
  }) {
    return AnnouncementData(
      id: id ?? this.id,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      department: department ?? this.department,
      readTime: readTime ?? this.readTime,
      isRead: isRead ?? this.isRead,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  static int priorityIndex(AnnouncementPriority p) {
    switch (p) {
      case AnnouncementPriority.critical:
        return 0;
      case AnnouncementPriority.urgent:
        return 1;
      case AnnouncementPriority.high:
        return 2;
      case AnnouncementPriority.pinned:
        return 3;
      case AnnouncementPriority.scheduled:
        return 4;
      case AnnouncementPriority.normal:
        return 5;
    }
  }
}
