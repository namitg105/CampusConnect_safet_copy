import 'package:flutter/material.dart';
import 'models/notification_model.dart';
import 'hardcoded/hardcoded_notification_requests.dart';
import 'hardcoded/hardcoded_notification_social.dart';
import 'hardcoded/hardcoded_notification_events.dart';
import 'components/notification_header.dart';
import 'components/notification_title_section.dart';
import 'components/notification_section_header.dart';
import 'components/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationData> _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = [
      ...hardcodedRequestNotifications,
      ...hardcodedSocialNotifications,
      ...hardcodedEventNotifications,
    ];
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationData> get _todayNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => n.timestamp.isAfter(todayStart))
        .toList();
  }

  List<NotificationData> get _earlierNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => !n.timestamp.isAfter(todayStart))
        .toList();
  }

  void _onDelete(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _onClearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationHeader(
                unreadCount: _unreadCount,
                showBackButton: true,
                onBackTap: () => Navigator.pop(context),
                onClearAllTap: _onClearAll,
              ),
              const SizedBox(height: 26),
              NotificationTitleSection(totalCount: _notifications.length),
              const SizedBox(height: 26),
              Expanded(child: _buildNotificationList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
          ),
        ),
      );
    }

    final today = _todayNotifications;
    final earlier = _earlierNotifications;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (today.isNotEmpty) ...[
          NotificationSectionHeader(
            label: 'TODAY',
            newCount: today.where((n) => !n.isRead).length,
          ),
          const SizedBox(height: 14),
          ...today.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: NotificationCard(
                  notification: n,
                  onDelete: () => _onDelete(n.id),
                ),
              )),
        ],
        if (earlier.isNotEmpty) ...[
          if (today.isNotEmpty) const SizedBox(height: 12),
          NotificationSectionHeader(
            label: 'EARLIER',
            newCount: earlier.where((n) => !n.isRead).length,
          ),
          const SizedBox(height: 14),
          ...earlier.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: NotificationCard(
                  notification: n,
                  onDelete: () => _onDelete(n.id),
                ),
              )),
        ],
      ],
    );
  }
}
