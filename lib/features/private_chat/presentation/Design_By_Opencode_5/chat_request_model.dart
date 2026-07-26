import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRequest {
  final String fromUid;
  final String fromName;
  final String fromEmail;
  final String fromImageURL;
  final String status;
  final DateTime timestamp;

  const ChatRequest({
    required this.fromUid,
    required this.fromName,
    required this.fromEmail,
    required this.fromImageURL,
    required this.status,
    required this.timestamp,
  });

  factory ChatRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRequest(
      fromUid: data['fromUid'] ?? '',
      fromName: data['fromName'] ?? '',
      fromEmail: data['fromEmail'] ?? '',
      fromImageURL: data['fromImageURL'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get initials {
    final parts = fromName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  static const _avatarColors = [
    Color(0xFFE8E0FF),
    Color(0xFFD4F5E9),
    Color(0xFFFFE0E6),
    Color(0xFFD4E6FF),
    Color(0xFFFFF3D4),
    Color(0xFFE0F0FF),
    Color(0xFFF0E0FF),
    Color(0xFFD4FFF0),
  ];

  Color get avatarColor {
    return _avatarColors[fromUid.hashCode.abs() % _avatarColors.length];
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
