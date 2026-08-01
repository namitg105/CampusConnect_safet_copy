import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../events/domain/entities/event.dart';
import '../../events/domain/repo/eventrepo.dart';
import '../domain/entities/group.dart';
import '../presentation/pages/community_profile.dart';
import '../presentation/pages/search_communities_page.dart';

// ==================== DESIGN TOKENS ====================

const Color _brandPrimary = Color(0xFF6366F1);
const Color _primaryPurple = Color(0xFF6C38FF);
const Color _lightPurpleBg = Color(0xFFF7F5FF);
const Color _cardBgColor = Color(0xFFF9F8FD);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _bgSurface = Color(0xFFF8FAFC);
const Color _borderColor = Color(0xFFEBEBF0);

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

  // Navigates to Search Communities Page
  void _openSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchCommunitiesPage(groups: widget.groups),
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  if (!isSearching) ...[
                    _JoinedCommunitiesSection(
                      allGroups: widget.groups,
                      onTapGroup: (g) => _navigateToGroupProfile(context, g),
                      onCreateCommunity: widget.onCreateCommunity,
                      onExploreMore: () => _openSearchPage(context),
                    ),
                    const SizedBox(height: 20),
                    if (_recentGroup != null) ...[
                      _ContinueWhereYouLeftOffCard(
                        recentGroup: _recentGroup,
                        onTapGroup: (g) => _navigateToGroupProfile(context, g),
                      ),
                      const SizedBox(height: 20),
                    ],
                    UpcomingEventsSection(groups: widget.groups),
                    const SizedBox(height: 20),
                    _TrendingCommunitiesSection(
                      fallbackGroups: widget.groups,
                      onTapGroup: (g) => _navigateToGroupProfile(context, g),
                      onExploreMore: () => _openSearchPage(context),
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
                const SizedBox(width: 175),
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
                children: const [
                  Text(
                    "Collaborate & grow together",
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Connect with peers, access shared resources, and exchange knowledge",
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
// "My Communities" Section (Filters for User Membership)
// ---------------------------------------------------------------------------
class _JoinedCommunitiesSection extends StatelessWidget {
  final List<Group> allGroups;
  final ValueChanged<Group> onTapGroup;
  final VoidCallback? onCreateCommunity;
  final VoidCallback? onExploreMore;

  const _JoinedCommunitiesSection({
    required this.allGroups,
    required this.onTapGroup,
    this.onCreateCommunity,
    this.onExploreMore,
  });

  Future<List<Group>> _getJoinedGroups() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return [];

    final List<Group> joined = [];

    try {
      // 1. Fetch joined group IDs from users/$currentUserId/joinedGroups
      final joinedDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('joinedGroups')
          .get();

      final joinedGroupIds = joinedDocs.docs.map((d) => d.id).toSet();
      final Map<String, Group> groupMap = {for (var g in allGroups) g.id: g};

      for (final id in joinedGroupIds) {
        if (groupMap.containsKey(id)) {
          joined.add(groupMap[id]!);
        } else {
          final groupDoc = await FirebaseFirestore.instance
              .collection('groups')
              .doc(id)
              .get();
          if (groupDoc.exists) {
            joined.add(Group.fromFirestore(groupDoc));
          }
        }
      }

      // 2. Fallback: check allGroups for memberDoc if joined list is empty
      if (joined.isEmpty) {
        for (final group in allGroups) {
          final memberDoc = await FirebaseFirestore.instance
              .collection('groups')
              .doc(group.id)
              .collection('members')
              .doc(currentUserId)
              .get();

          if (memberDoc.exists) {
            joined.add(group);
          }
        }
      }
    } catch (e) {
      print("Error fetching joined groups: $e");
    }

    return joined;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "My Communities",
          onViewAll: onExploreMore,
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Group>>(
          future: _getJoinedGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _brandPrimary,
                  ),
                ),
              );
            }

            final myGroups = snapshot.data ?? [];

            if (myGroups.isEmpty) {
              return _EmptyCommunityTile(
                message: "No communities joined yet",
                buttonLabel: "Create or Join",
                onTap: onCreateCommunity ?? onExploreMore,
              );
            }

            return SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: myGroups.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == myGroups.length) {
                    return _ExploreMoreTile(onTap: onExploreMore);
                  }
                  final group = myGroups[index];
                  return _MyCommunityCard(
                    group: group,
                    onTap: () => onTapGroup(group),
                  );
                },
              ),
            );
          },
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

                // REAL-TIME ONLINE MEMBERS & MEMBER COUNT STREAM
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(group.id)
                      .collection('members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int onlineCount = 0;
                    if (snapshot.hasData) {
                      onlineCount = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>?;
                        return data?['isOnline'] == true;
                      }).length;
                    }
                    if (onlineCount == 0) onlineCount = 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                            radius: 3, backgroundColor: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "$onlineCount Online",
                          style:
                              const TextStyle(fontSize: 8.5, color: _textMuted),
                        ),
                      ],
                    );
                  },
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
  final VoidCallback? onTap;

  const _ExploreMoreTile({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('groups')
                          .doc(recentGroup!.id)
                          .collection('members')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final count =
                            snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          "$count Members",
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 9,
                          ),
                        );
                      },
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
// Upcoming Events Section (Strictly Filtered by Joined Communities)
// ---------------------------------------------------------------------------
class UpcomingEventsSection extends StatelessWidget {
  final List<Group> groups;

  const UpcomingEventsSection({
    super.key,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: "Upcoming Events"),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, eventsSnapshot) {
              if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6366F1),
                  ),
                );
              }

              if (eventsSnapshot.hasError ||
                  !eventsSnapshot.hasData ||
                  eventsSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No upcoming events",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                );
              }

              final allEventDocs = eventsSnapshot.data!.docs;

              return FutureBuilder<List<Event>>(
                future: _filterEventsForMember(allEventDocs, currentUserId),
                builder: (context, memberEventsSnapshot) {
                  if (memberEventsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6366F1),
                      ),
                    );
                  }

                  final joinedEvents = memberEventsSnapshot.data ?? [];

                  if (joinedEvents.isEmpty) {
                    return const Center(
                      child: Text(
                        "No upcoming events in your communities",
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    );
                  }

                  joinedEvents.sort((a, b) => a.date.compareTo(b.date));

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: joinedEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _EventCard(event: joinedEvents[index]);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Event>> _filterEventsForMember(
      List<QueryDocumentSnapshot> eventDocs, String userId) async {
    final List<Event> memberEvents = [];

    for (var doc in eventDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final groupId = data['groupId'] ?? '';
      final status = data['status'] ?? 'active';

      if (groupId.isEmpty || status == 'cancelled') continue;

      final memberDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        memberEvents.add(Event.fromMap(doc.id, data));
      }
    }

    return memberEvents;
  }
}

// ---------------------------------------------------------------------------
// Event Card Component
// ---------------------------------------------------------------------------
class _EventCard extends StatefulWidget {
  final Event event;

  const _EventCard({super.key, required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  void _navigateToDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          event: widget.event,
          groupId: widget.event.groupId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String month =
        DateFormat('MMM').format(widget.event.date).toUpperCase();
    final String day = DateFormat('dd').format(widget.event.date);
    final String timeStr =
        DateFormat('h.mm a').format(widget.event.date).toUpperCase();
    final String dayLabel = _relativeDayLabel(widget.event.date);

    return GestureDetector(
      onTap: _navigateToDetails,
      child: Container(
        width: 160,
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
                  width: 32,
                  decoration: BoxDecoration(
                    color: _primaryPurple,
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
                      Container(
                          height: 1, color: Colors.white.withOpacity(0.2)),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 5),
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                          fontSize: 12,
                          color: Color(0xFF0F172A),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$dayLabel, $timeStr",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            StreamBuilder<DocumentSnapshot>(
              stream: EventRepository().streamEventDetails(widget.event.id),
              builder: (context, snapshot) {
                int filledSpots = 0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  filledSpots = data?['filledSpots'] ?? 0;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
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
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF636366),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 75,
                      height: 22,
                      child: ElevatedButton(
                        onPressed: _navigateToDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
// Dynamic Trending Communities Section (Sorted by Average Rating & Members)
// ---------------------------------------------------------------------------
class _TrendingCommunitiesSection extends StatelessWidget {
  final List<Group> fallbackGroups;
  final ValueChanged<Group> onTapGroup;
  final VoidCallback? onExploreMore;

  const _TrendingCommunitiesSection({
    required this.fallbackGroups,
    required this.onTapGroup,
    this.onExploreMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Trending Communities",
          onViewAll: onExploreMore,
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .orderBy('averageRating', descending: true)
              .limit(10)
              .snapshots(),
          builder: (context, snapshot) {
            List<QueryDocumentSnapshot> trendingDocs = [];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              trendingDocs = snapshot.data!.docs;
            }

            if (trendingDocs.isEmpty && fallbackGroups.isEmpty) {
              return _EmptyCommunityTile(
                message: "No trending communities available",
                buttonLabel: "Explore Communities",
                onTap: onExploreMore,
              );
            }

            final displayCount = trendingDocs.isNotEmpty
                ? trendingDocs.length
                : fallbackGroups.length;

            return SizedBox(
              height: 145,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayCount,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (trendingDocs.isNotEmpty) {
                    final doc = trendingDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final groupObj = Group(
                      id: doc.id,
                      name: data['name'] ?? 'Community',
                      description: data['description'] ?? '',
                      imageUrl: data['imageUrl'] ?? '',
                      createdBy: data['createdBy'] ?? data['adminId'] ?? '',
                      collegeId: data['collegeId'] ?? '',
                      category: data['category'] ?? 'General',
                      isPublic: data['isPublic'] ?? true,
                      rules: List<String>.from(data['rules'] ?? []),
                      memberCount: data['memberCount'] ?? 0,
                      maxMembers: data['maxMembers'] ?? 100,
                      remainingSeats: data['remainingSeats'] ?? 100,
                    );
                    final double avgRating =
                        (data['averageRating'] ?? 4.5).toDouble();

                    return _TrendingCommunityCard(
                      group: groupObj,
                      rating: avgRating,
                      onTap: () => onTapGroup(groupObj),
                    );
                  } else {
                    final group = fallbackGroups[index];
                    return _TrendingCommunityCard(
                      group: group,
                      rating: 4.5,
                      onTap: () => onTapGroup(group),
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TrendingCommunityCard extends StatelessWidget {
  final Group group;
  final double rating;
  final VoidCallback onTap;

  const _TrendingCommunityCard({
    required this.group,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 115,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 54,
              width: double.infinity,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(group.id)
                        .collection('members')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count =
                          snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return Text(
                        "$count Members",
                        style: const TextStyle(
                          fontSize: 9,
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
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

// ==================== EVENT DETAILS SCREEN ====================

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final String groupId;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.groupId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isActionLoading = false;

  void _addToCalendar() {
    final calendar.Event calEvent = calendar.Event(
      title: widget.event.title,
      description: widget.event.description,
      location: widget.event.location,
      startDate: widget.event.date,
      endDate: widget.event.date.add(const Duration(hours: 2)),
      iosParams: const calendar.IOSParams(
        reminder: Duration(minutes: 30),
      ),
      androidParams: const calendar.AndroidParams(
        emailInvites: [],
      ),
    );

    try {
      calendar.Add2Calendar.addEvent2Cal(calEvent);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open calendar: $e')),
        );
      }
    }
  }

  Future<void> _handleRSVP(bool isCurrentlyRegistered) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to respond to events')),
      );
      return;
    }

    setState(() => _isActionLoading = true);

    try {
      final eventDocRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      final rsvpRef = eventDocRef.collection('rsvps').doc(user.uid);

      if (isCurrentlyRegistered) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final rsvpSnapshot = await transaction.get(rsvpRef);
          if (!rsvpSnapshot.exists) return;

          transaction.delete(rsvpRef);
          transaction.update(eventDocRef, {
            'filledSpots': FieldValue.increment(-1),
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration canceled.')),
          );
        }
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>?;

        final String userName = userData?['name'] ??
            userData?['displayName'] ??
            user.email?.split('@').first ??
            'Member';
        final String userAvatarUrl = userData?['imageUrl'] ??
            userData?['photoUrl'] ??
            userData?['profileImage'] ??
            '';

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final rsvpSnapshot = await transaction.get(rsvpRef);
          if (rsvpSnapshot.exists) {
            throw Exception("You have already registered for this event.");
          }

          transaction.set(rsvpRef, {
            'userId': user.uid,
            'userEmail': user.email ?? '',
            'userName': userName,
            'userAvatarUrl': userAvatarUrl,
            'registeredAt': FieldValue.serverTimestamp(),
          });

          transaction.update(eventDocRef, {
            'filledSpots': FieldValue.increment(1),
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully registered for event!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final DateTime eventDate = widget.event.date;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .snapshots(),
      builder: (context, eventSnapshot) {
        bool isCancelled = false;
        if (eventSnapshot.hasData && eventSnapshot.data!.exists) {
          final data = eventSnapshot.data!.data() as Map<String, dynamic>?;
          isCancelled = data?['status'] == 'cancelled';
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                EventDetailsHeader(onBack: () => Navigator.of(context).pop()),
                if (isCancelled)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'EVENT CANCELLED BY ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: EventHeroBanner(event: widget.event),
                        ),
                        const SizedBox(height: 12),
                        if (!isCancelled)
                          StreamBuilder<DocumentSnapshot>(
                            stream: user != null
                                ? FirebaseFirestore.instance
                                    .collection('events')
                                    .doc(widget.event.id)
                                    .collection('rsvps')
                                    .doc(user.uid)
                                    .snapshots()
                                : null,
                            builder: (context, snapshot) {
                              final isRegistered =
                                  snapshot.hasData && snapshot.data!.exists;

                              return EventActionButtons(
                                isRegistered: isRegistered,
                                isLoading: _isActionLoading,
                                onRegister: () => _handleRSVP(isRegistered),
                                onCalendar: _addToCalendar,
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        EventInfoGridHorizontal(
                          dateStr: DateFormat('MMM dd, yyyy').format(eventDate),
                          weekdayStr: DateFormat('EEEE').format(eventDate),
                          timeStr: DateFormat('h.mm a')
                              .format(eventDate)
                              .toUpperCase(),
                          venue: widget.event.location,
                          format: widget.event.format ?? 'Hybrid event',
                        ),
                        const SizedBox(height: 16),
                        AboutEventCard(
                          description: widget.event.description,
                        ),
                        const SizedBox(height: 12),
                        SpeakerCard(
                          speakerName:
                              widget.event.speakerName ?? 'Guest Speaker',
                          speakerDescription: widget.event.speakerDescription ??
                              'Event Host & Keynote Presenter',
                          speakerAvatarUrl: widget.event.speakerAvatarUrl ??
                              'https://picsum.photos/id/1027/200',
                        ),
                        const SizedBox(height: 12),
                        RegisteredUsersFooter(
                          groupId: widget.groupId,
                          eventId: widget.event.id,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== SUB-COMPONENTS ====================

class EventDetailsHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const EventDetailsHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
          const Text(
            'Event Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class EventHeroBanner extends StatelessWidget {
  final Event event;

  const EventHeroBanner({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(
            event.bannerUrl ?? 'https://picsum.photos/id/237/900/500',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.category ?? 'Workshop',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EventActionButtons extends StatelessWidget {
  final bool isRegistered;
  final bool isLoading;
  final VoidCallback? onRegister;
  final VoidCallback? onCalendar;

  const EventActionButtons({
    super.key,
    this.isRegistered = false,
    this.isLoading = false,
    this.onRegister,
    this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onRegister,
                icon: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isRegistered
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 16,
                      ),
                label: Text(
                  isRegistered ? 'Attending (Cancel)' : 'Register Now',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRegistered ? Colors.green : _primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: onCalendar,
                icon: const Icon(Icons.calendar_today_outlined, size: 14),
                label: const Text(
                  'Add to Calendar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lightPurpleBg,
                  foregroundColor: _primaryPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventInfoGridHorizontal extends StatelessWidget {
  final String dateStr;
  final String weekdayStr;
  final String timeStr;
  final String venue;
  final String format;

  const EventInfoGridHorizontal({
    super.key,
    required this.dateStr,
    required this.weekdayStr,
    required this.timeStr,
    required this.venue,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(
              Icons.calendar_today_outlined, 'Date', dateStr, weekdayStr),
          _buildDivider(),
          _buildItem(Icons.access_time, 'Time', timeStr, null),
          _buildDivider(),
          _buildItem(Icons.location_on_outlined, 'Location', venue, null),
          _buildDivider(),
          _buildItem(Icons.videocam_outlined, 'Format', format, null),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: _borderColor,
    );
  }

  Widget _buildItem(IconData icon, String title, String val1, String? val2) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: _primaryPurple),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: _textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            val1,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          if (val2 != null)
            Text(
              val2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
        ],
      ),
    );
  }
}

class AboutEventCard extends StatelessWidget {
  final String description;

  const AboutEventCard({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this Event',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: _textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class SpeakerCard extends StatelessWidget {
  final String speakerName;
  final String speakerDescription;
  final String speakerAvatarUrl;

  const SpeakerCard({
    super.key,
    required this.speakerName,
    required this.speakerDescription,
    required this.speakerAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Speakers',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _lightPurpleBg,
                backgroundImage: speakerAvatarUrl.isNotEmpty
                    ? NetworkImage(speakerAvatarUrl)
                    : null,
                child: speakerAvatarUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: _primaryPurple,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speakerName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      speakerDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisteredUsersFooter extends StatelessWidget {
  final String groupId;
  final String eventId;

  const RegisteredUsersFooter({
    super.key,
    required this.groupId,
    required this.eventId,
  });

  String _getInitials(String nameOrEmail) {
    if (nameOrEmail.isEmpty) return '??';
    final clean = nameOrEmail
        .split('@')
        .first
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), ' ')
        .trim();
    final parts = clean.split(RegExp(r'\s+'));

    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts[0].isNotEmpty && parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    } else if (parts[0].isNotEmpty) {
      return parts[0].toUpperCase();
    } else {
      return '??';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('rsvps')
          .orderBy('registeredAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.hasData ? snapshot.data!.docs : [];
        final registeredCount = docs.length;
        final displayDocs = docs.take(4).toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$registeredCount',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Interested',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 36, width: 1, color: _borderColor),
              Expanded(
                flex: 2,
                child: Center(
                  child: SizedBox(
                    width: 130,
                    height: 28,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        for (int i = 0; i < displayDocs.length; i++) ...[
                          _buildUserAvatarTile(
                            data: displayDocs[i].data() as Map<String, dynamic>,
                            leftPadding: i * 22.0,
                          ),
                        ],
                        if (registeredCount > 4)
                          _buildCountBadge(
                            '+${registeredCount - 4}',
                            displayDocs.length * 22.0,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 36, width: 1, color: _borderColor),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$registeredCount',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Registered',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatarTile({
    required Map<String, dynamic> data,
    required double leftPadding,
  }) {
    final String avatarUrl = data['userAvatarUrl'] ?? '';
    final String nameOrEmail = data['userName'] ?? data['userEmail'] ?? 'User';

    return Positioned(
      left: leftPadding,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _lightPurpleBg,
          shape: BoxShape.circle,
          border: Border.all(color: _primaryPurple, width: 1.5),
          image: avatarUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: avatarUrl.isEmpty
            ? Center(
                child: Text(
                  _getInitials(nameOrEmail),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _primaryPurple,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCountBadge(String label, double leftPadding) {
    return Positioned(
      left: leftPadding,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _primaryPurple,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
