import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteswap/features/notifications/presentation/screens/notification.dart';

import '../../events/domain/entities/event.dart';
import '../../events/domain/repo/eventrepo.dart';
import '../domain/entities/group.dart';
import '../presentation/pages/community_profile.dart';
import '../presentation/pages/search_communities_page.dart';

const Color _brandPrimary = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _bgSurface = Color(0xFFF8FAFC);

class CommunitiesPage extends StatefulWidget {
  final List<Group> groups;
  final VoidCallback? onCreateCommunity;

  const CommunitiesPage({
    super.key,
    required this.groups,
    this.onCreateCommunity,
  });

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  // Tracks the most recently opened community card
  Group? _recentGroup;

  // Get current user's name dynamically from Firebase Auth
  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      return user.displayName!.split(' ').first; // First name
    }
    return "there";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigates to the Group Profile Page
  void _navigateToGroupProfile(BuildContext context, Group group) {
    setState(() {
      _recentGroup = group;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupProfilePage(
          groupId: group.id,
        ),
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = widget.groups.where((group) {
      final query = _searchQuery.toLowerCase();
      return group.name.toLowerCase().contains(query) ||
          group.description.toLowerCase().contains(query);
    }).toList();

    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER & SEARCH BAR SECTION
            Container(
              color: _bgSurface,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(
                    greeting: _greeting,
                    userName: _displayName,
                    onCreateCommunity: widget.onCreateCommunity,
                  ),
                  const SizedBox(height: 16),
                  _SearchBar(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    groups: widget.groups,
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT SECTION
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  if (!isSearching) ...[
                    _MyCommunitiesSection(
                      groups: widget.groups,
                      onTapGroup: (g) => _navigateToGroupProfile(context, g),
                      onCreateCommunity: widget.onCreateCommunity,
                    ),
                    const SizedBox(height: 20),
                    if (_recentGroup != null) ...[
                      _ContinueWhereYouLeftOffCard(
                        recentGroup: _recentGroup,
                        onTapGroup: (g) => _navigateToGroupProfile(context, g),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const UpcomingEventsSection(),
                    const SizedBox(height: 20),
                    _TrendingCommunitiesSection(
                      groups: widget.groups,
                      onTapGroup: (g) => _navigateToGroupProfile(context, g),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _SearchResultsList(
                      groups: filteredGroups,
                      onTapGroup: (g) => _navigateToGroupProfile(context, g),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String userName;
  final VoidCallback? onCreateCommunity;

  const _Header({
    required this.greeting,
    required this.userName,
    required this.onCreateCommunity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: _textDark,
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  "assets/header1.png",
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.bubble_chart_rounded,
                    color: _brandPrimary,
                    size: 32,
                  ),
                ),
              ],
            ),
            _NotificationButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Collaborate & grow together",
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Connect with peers, access shared resources, and exchange knowledge",
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onCreateCommunity,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                "Create community",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Image.asset(
            "assets/community/Notified_bell.png",
            height: 22,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.notifications_none_rounded,
              color: _textDark,
              size: 22,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final List<Group> groups;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.groups,
  });

  void _openSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchCommunitiesPage(groups: groups),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openSearchPage(context),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Search Communities",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _openSearchPage(context),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/community/filter.png",
                  height: 16,
                  width: 16,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.filter_list_rounded,
                    color: _brandPrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "Filters",
                  style: TextStyle(
                    color: _brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: _textDark,
            fontSize: 15,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              "View all ›",
              style: TextStyle(
                color: _brandPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// "My Communities" Section
// ---------------------------------------------------------------------------
class _MyCommunitiesSection extends StatelessWidget {
  final List<Group> groups;
  final ValueChanged<Group> onTapGroup;
  final VoidCallback? onCreateCommunity;

  const _MyCommunitiesSection({
    required this.groups,
    required this.onTapGroup,
    this.onCreateCommunity,
  });

  @override
  Widget build(BuildContext context) {
    final myGroups = groups.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "My Communities", onViewAll: () {}),
        const SizedBox(height: 12),
        if (myGroups.isEmpty)
          _EmptyCommunityTile(
            message: "No communities joined yet",
            buttonLabel: "Create or Join",
            onTap: onCreateCommunity,
          )
        else
          SizedBox(
            height: 125,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: myGroups.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == myGroups.length) {
                  return const _ExploreMoreTile();
                }
                final group = myGroups[index];
                return _MyCommunityCard(
                  group: group,
                  onTap: () => onTapGroup(group),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _MyCommunityCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const _MyCommunityCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Color(0xFF0F172A),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: group.imageUrl.trim().isNotEmpty
                  ? Image.network(
                      group.imageUrl.trim(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.code_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.code_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(radius: 3, backgroundColor: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      "198 Online",
                      style: TextStyle(fontSize: 8.5, color: _textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF2FF),
                      foregroundColor: _brandPrimary,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Open",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ExploreMoreTile extends StatelessWidget {
  const _ExploreMoreTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            backgroundColor: Color(0xFFF1F5F9),
            radius: 20,
            child: Icon(Icons.add_rounded, color: _brandPrimary, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            "Explore more",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dynamic "Continue Where You Left Off" Section
// ---------------------------------------------------------------------------
class _ContinueWhereYouLeftOffCard extends StatelessWidget {
  final Group? recentGroup;
  final ValueChanged<Group> onTapGroup;

  const _ContinueWhereYouLeftOffCard({
    required this.recentGroup,
    required this.onTapGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (recentGroup == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: "Continue where you left off"),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 90,
                  height: 65,
                  color: const Color(0xFF0F172A),
                  child: recentGroup!.imageUrl.trim().isNotEmpty
                      ? Image.network(
                          recentGroup!.imageUrl.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.groups_rounded,
                            color: Colors.white70,
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.groups_rounded,
                          color: Colors.white70,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentGroup!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recentGroup!.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _brandPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${recentGroup!.memberCount} Members",
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () => onTapGroup(recentGroup!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Open Profile",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming Events Section (Firebase-powered)
// ---------------------------------------------------------------------------
class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: "Upcoming Events"),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .orderBy('date')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _brandPrimary,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading events: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No upcoming events",
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                );
              }

              final events = snapshot.data!.docs.map((doc) {
                return Event.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _EventCard(event: events[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Event Card Component (Restored original UI layout)
// ---------------------------------------------------------------------------
class _EventCard extends StatefulWidget {
  final Event event;

  const _EventCard({super.key, required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isRegistering = false;
  final EventRepository _eventRepo = EventRepository();

  Future<void> _handleRSVP() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isRegistering = true);

    try {
      await _eventRepo.rsvpToEvent(
        eventId: widget.event.id,
        userId: user.uid,
        userEmail: user.email ?? '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered for event!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String month =
        DateFormat('MMM').format(widget.event.date).toUpperCase();
    final String day = DateFormat('dd').format(widget.event.date);
    final String timeStr =
        DateFormat('h.mm a').format(widget.event.date).toUpperCase();
    final String dayLabel = _relativeDayLabel(widget.event.date);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C38FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 2),
                      child: Text(
                        month,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(height: 1, color: Colors.white.withOpacity(0.2)),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 5),
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$dayLabel,$timeStr",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: EventRepository().streamEventDetails(widget.event.id),
            builder: (context, snapshot) {
              int filledSpots = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                filledSpots = data?['filledSpots'] ?? 0;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, bottom: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE5E5EA),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        "+$filledSpots",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF636366),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, bottom: 1),
                    child: SizedBox(
                      width: 80,
                      height: 20,
                      child: ElevatedButton(
                        onPressed: _isRegistering ? null : _handleRSVP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C38FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isRegistering
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _relativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Tomorrow";
    if (diff > 1 && diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d').format(date);
  }
}

// ---------------------------------------------------------------------------
// Trending Communities Section
// ---------------------------------------------------------------------------
class _TrendingCommunitiesSection extends StatelessWidget {
  final List<Group> groups;
  final ValueChanged<Group> onTapGroup;

  const _TrendingCommunitiesSection({
    required this.groups,
    required this.onTapGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "Trending Communities", onViewAll: () {}),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          const _EmptyCommunityTile(
            message: "No trending communities available",
          )
        else
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _TrendingCommunityCard(
                  group: group,
                  onTap: () => onTapGroup(group),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TrendingCommunityCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const _TrendingCommunityCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Color(0xFF0F172A),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: group.imageUrl.trim().isNotEmpty
                    ? Image.network(
                        group.imageUrl.trim(),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.groups_rounded,
                            color: _brandPrimary,
                            size: 24,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.groups_rounded,
                          color: _brandPrimary,
                          size: 24,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    "${group.memberCount} Members",
                    style: const TextStyle(fontSize: 8.5, color: _textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 10),
                      SizedBox(width: 2),
                      Text(
                        "4.5",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fallback Container for Empty States
// ---------------------------------------------------------------------------
class _EmptyCommunityTile extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onTap;

  const _EmptyCommunityTile({
    required this.message,
    this.buttonLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 32,
            color: _textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
          if (buttonLabel != null && onTap != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FF),
                foregroundColor: _brandPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search Results List Component
// ---------------------------------------------------------------------------
class _SearchResultsList extends StatelessWidget {
  final List<Group> groups;
  final ValueChanged<Group> onTapGroup;

  const _SearchResultsList({required this.groups, required this.onTapGroup});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            "No communities match your search.",
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "Search Results",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontSize: 15,
            ),
          ),
        ),
        ...groups.map(
          (group) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              group.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              group.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => onTapGroup(group),
          ),
        ),
      ],
    );
  }
}
