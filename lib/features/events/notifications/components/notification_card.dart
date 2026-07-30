import 'package:flutter/material.dart';
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
    return Builder(
      builder: (context) {
        try {
          return GestureDetector(
            onTap: () {
              try {
                FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(notification.id)
                    .update({'isRead': true});
              } catch (_) {}
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
            ),
          );
        } catch (e) {
          // Graceful Error Boundary Card
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withValues(alpha: 0.04),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF6139ED),
                  child: Icon(Icons.notifications, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title.isNotEmpty ? notification.title : 'Notification',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      if (notification.description != null && notification.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.description!,
                          style: const TextStyle(color: Color(0xFF7E7E7E), fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildContent() {
    switch (notification.type) {
      case NotificationType.requestChatPrivate:
      case NotificationType.requestChatGroup:
        return _buildRequestContent();
      case NotificationType.postCommented:
      case NotificationType.newPost:
        return _buildSocialContent();
      case NotificationType.event:
      case NotificationType.announcement:
        return _buildEventContent();
    }
  }

  Widget _buildRequestContent() {
    final name = (notification.appUser != null && notification.appUser!.name.trim().isNotEmpty)
        ? notification.appUser!.name
        : (notification.title.startsWith('New message from ')
            ? notification.title.replaceFirst('New message from ', '').trim()
            : 'Someone');
    final action = notification.title.startsWith('New message from ')
        ? 'sent a message'
        : (notification.title.replaceFirst(name, '').trim().isNotEmpty
            ? notification.title.replaceFirst(name, '').trim()
            : 'interacted with you');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationRichContent(
          name: name.isNotEmpty ? name : 'Someone',
          action: action,
          subtitle: (notification.societyName != null && notification.societyName!.isNotEmpty)
              ? notification.societyName
              : null,
          timestamp: _formatTimestamp(notification.timestamp),
        ),
        if (notification.description != null && notification.description!.trim().isNotEmpty) ...[
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
        if (onAccept != null || onDecline != null)
          FriendRequestActions(
            onAccept: onAccept,
            onDecline: onDecline,
          ),
      ],
    );
  }

  Widget _buildSocialContent() {
    final name = (notification.appUser != null && notification.appUser!.name.trim().isNotEmpty)
        ? notification.appUser!.name
        : 'Someone';
    final action = notification.title.startsWith(name)
        ? notification.title.replaceFirst(name, '').trim()
        : notification.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationRichContent(
          name: name,
          action: action,
          subtitle: notification.societyName ?? notification.subtitle,
          timestamp: _formatTimestamp(notification.timestamp),
        ),
        if (notification.description != null && notification.description!.trim().isNotEmpty) ...[
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
    );
  }

  String _formatTimestamp(DateTime dt) {
    try {
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Just now';
    }
  }
}
