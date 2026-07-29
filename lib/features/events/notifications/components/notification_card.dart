import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'notification_avatar.dart';
import 'notification_rich_content.dart';
import 'friend_request_actions.dart';
import 'event_reminder_card.dart';

class NotificationCard extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback? onDelete;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onDelete,
    this.onAccept,
    this.onDecline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        if (uid.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .doc(notification.id)
              .update({'isRead': true});
        }
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationAvatar(
              appUser: notification.appUser,
              actionIcon: notification.actionIcon,
              actionColor: notification.actionColor,
              fallbackColor: notification.avatarColor,
            fallbackInitials: notification.initials,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildContent(),
          ),
          const SizedBox(width: 8),
          _buildTrailing(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (notification.type) {
      case NotificationType.requestChatPrivate:
      case NotificationType.requestChatGroup:
        return _buildRequestContent();
      case NotificationType.postCommented:
        return _buildSocialContent();
      case NotificationType.event:
      case NotificationType.announcement:
        return _buildEventContent();
    }
  }

  Widget _buildRequestContent() {
    final name = notification.appUser?.name ?? 'Unknown';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationRichContent(
          name: name,
          action: notification.title.replaceFirst(name, '').trim(),
          subtitle: notification.societyName ?? notification.subtitle,
          timestamp: _formatTimestamp(notification.timestamp),
        ),
        if (notification.description != null) ...[
          const SizedBox(height: 6),
          Text(
            notification.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ],
        FriendRequestActions(
          onAccept: onAccept,
          onDecline: onDecline,
        ),
      ],
    );
  }

  Widget _buildSocialContent() {
    final name = notification.appUser?.name ?? 'Unknown';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationRichContent(
          name: name,
          action: notification.title,
          subtitle: notification.societyName ?? notification.subtitle,
          timestamp: _formatTimestamp(notification.timestamp),
        ),
        if (notification.description != null) ...[
          const SizedBox(height: 6),
          Text(
            notification.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventContent() {
    return EventReminderCard(
      eventMonth: notification.eventMonth,
      eventDate: notification.eventDate != null
          ? '${notification.eventDate!.day}'
          : null,
      reminderLabel: notification.reminderLabel ?? 'EVENT',
      title: notification.title,
      location: notification.eventLocation ?? notification.subtitle,
    );
  }

  Widget _buildTrailing() {
    return Column(
      children: [
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF7C5CFA),
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 8),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(
            Icons.delete_outline,
            color: Color(0xFFD0D0D0),
            size: 18,
          ),
        ),
      ],
    ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
