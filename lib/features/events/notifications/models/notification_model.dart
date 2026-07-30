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
    try {
      final nameToUse = (appUser != null && appUser!.name.trim().isNotEmpty)
          ? appUser!.name
          : (title.startsWith('New message from ')
              ? title.replaceFirst('New message from ', '')
              : title);
      final trimmed = nameToUse.trim();
      if (trimmed.isEmpty || trimmed == '?') return '?';
      
      final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.isEmpty) return '?';

      if (words.length >= 2) {
        final first = words[0].substring(0, 1);
        final second = words[1].substring(0, 1);
        return (first + second).toUpperCase();
      } else {
        return words[0].substring(0, 1).toUpperCase();
      }
    } catch (_) {
      return '?';
    }
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
