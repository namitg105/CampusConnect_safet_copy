import 'package:flutter/material.dart';
import '../../../auth/domain/entities/app_user.dart';

enum NotificationType {
  requestChatPrivate,
  requestChatGroup,
  postCommented,
  newPost,
  event,
  announcement,
}

class NotificationData {
  final String id;
  final NotificationType type;
  final AppUser? appUser;
  final String title;
  final String? subtitle;
  final String? description;
  final DateTime timestamp;
  final bool isRead;
  final IconData? actionIcon;
  final Color? actionColor;
  final DateTime? eventDate;
  final String? eventLocation;
  final String? eventMonth;
  final String? reminderLabel;
  final String? societyName;

  const NotificationData({
    required this.id,
    required this.type,
    this.appUser,
    required this.title,
    this.subtitle,
    this.description,
    required this.timestamp,
    this.isRead = false,
    this.actionIcon,
    this.actionColor,
    this.eventDate,
    this.eventLocation,
    this.eventMonth,
    this.reminderLabel,
    this.societyName,
  });

  String get initials {
    if (appUser == null || appUser!.name.isEmpty) return '?';
    final parts = appUser!.name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return appUser!.name[0].toUpperCase();
  }

  Color get avatarColor {
    const colors = [
      Color(0xFFE9E3FF),
      Color(0xFFFFE2EC),
      Color(0xFFDDF8EA),
      Color(0xFFDCEAFF),
      Color(0xFFFFF1C8),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }

  Color get avatarTextColor {
    final luminance = avatarColor.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF4E4EAA) : Colors.white;
  }
}
