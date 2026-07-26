import 'package:flutter/material.dart';
import 'package:noteswap/features/events/notifications/notifications_screen.dart';
import 'models/announcement_model.dart';
import 'hardcoded/hardcoded_announcements_university.dart';
import 'hardcoded/hardcoded_announcements_club.dart';
import 'hardcoded/hardcoded_announcements_events.dart';
import 'components/announcement_header.dart';
import 'components/announcement_title_section.dart';
import 'components/announcement_tab_bar.dart';
import 'components/announcement_card.dart';
import 'components/featured_announcement_card.dart';
import 'components/section_divider_label.dart';

enum AnnouncementTab { all, university, club, events }

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  AnnouncementTab _selectedTab = AnnouncementTab.all;
  late List<AnnouncementData> _allAnnouncements;

  @override
  void initState() {
    super.initState();
    _allAnnouncements = [
      ...hardcodedUniversityAnnouncements,
      ...hardcodedClubAnnouncements,
      ...hardcodedEventAnnouncements,
    ];
  }

  List<AnnouncementData> get _filteredAnnouncements {
    List<AnnouncementData> list;
    switch (_selectedTab) {
      case AnnouncementTab.university:
        list = hardcodedUniversityAnnouncements;
      case AnnouncementTab.club:
        list = hardcodedClubAnnouncements;
      case AnnouncementTab.events:
        list = hardcodedEventAnnouncements;
      case AnnouncementTab.all:
        list = _allAnnouncements;
    }

    list.sort((a, b) {
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return a.timestamp.compareTo(b.timestamp);
    });
    return list;
  }

  List<AnnouncementData> get _featured =>
      _filteredAnnouncements.where((a) => a.isFeatured).toList();

  List<AnnouncementData> get _pinned =>
      _filteredAnnouncements.where((a) => !a.isFeatured && a.isPinned).toList();

  List<AnnouncementData> get _recent =>
      _filteredAnnouncements.where((a) => !a.isFeatured && !a.isPinned).toList();

  int get _pinnedCount => _filteredAnnouncements.where((a) => a.isPinned).length;

  void _markAllRead() {
    setState(() {
      _allAnnouncements = _allAnnouncements.map((a) => a.copyWith(isRead: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'University', 'Club', 'Events'];
    final icons = [
      Icons.grid_view_rounded,
      Icons.school_outlined,
      Icons.groups_outlined,
      Icons.event_outlined,
    ];
    final tabIndex = AnnouncementTab.values.indexOf(_selectedTab);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    AnnouncementHeader(
                      showBackButton: true,
                      onBackTap: () => Navigator.pop(context),
                      onNotificationTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              AnnouncementTitleSection(
                totalCount: _filteredAnnouncements.length,
                pinnedCount: _pinnedCount,
                onMarkAllRead: _markAllRead,
              ),
              const SizedBox(height: 20),
              AnnouncementTabBar(
                selectedIndex: tabIndex,
                labels: tabs,
                icons: icons,
                onTabSelected: (i) {
                  setState(() => _selectedTab = AnnouncementTab.values[i]);
                },
              ),
              const SizedBox(height: 28),
              if (_featured.isNotEmpty) ...[
                const SectionDividerLabel(label: 'FEATURED'),
                const SizedBox(height: 12),
                for (final a in _featured) ...[
                  FeaturedAnnouncementCard(announcement: a),
                  const SizedBox(height: 12),
                ],
              ],
              if (_pinned.isNotEmpty) ...[
                const SizedBox(height: 4),
                const SectionDividerLabel(label: 'PINNED'),
                const SizedBox(height: 12),
                for (final a in _pinned) ...[
                  AnnouncementCard(announcement: a),
                  const SizedBox(height: 12),
                ],
              ],
              if (_recent.isNotEmpty) ...[
                const SizedBox(height: 4),
                const SectionDividerLabel(label: 'RECENT'),
                const SizedBox(height: 12),
                for (final a in _recent) ...[
                  AnnouncementCard(announcement: a),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
