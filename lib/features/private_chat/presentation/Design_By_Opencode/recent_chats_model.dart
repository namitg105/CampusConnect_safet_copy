import 'package:flutter/material.dart';

class ConversationData {
  final String uid;
  final String? chatRoomId;
  final String? imageUrl;
  final String name;
  final String initials;
  final Color avatarColor;
  final String? lastMessage;
  final String? time;
  final bool isOnline;
  final int unreadCount;
  final bool isBlocked;

  const ConversationData(
    {
    required this.uid,
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.chatRoomId,
    this.imageUrl,
    this.lastMessage,
    this.time,
    this.isOnline = false,
    this.unreadCount = 0,
    this.isBlocked = false,
  });

  Color get avatarTextColor {
    final luminance = avatarColor.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF4E4EAA) : Colors.white;
  }
}
