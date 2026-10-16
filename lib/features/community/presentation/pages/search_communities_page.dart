import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../chat/presentation/pages/chatPage.dart';
import '../bloc/membership/membership_bloc.dart';
import '../../domain/entities/group.dart';

/// Search & join communities. Owns a MembershipBloc for the current user.
class SearchCommunitiesPage extends StatelessWidget {
  final List<Group> groups;

  const SearchCommunitiesPage({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : '';
    return BlocProvider(
      create: (_) => sl<MembershipBloc>()..add(MembershipWatchStarted(userId)),
      child: _SearchCommunitiesView(groups: groups, userId: userId),
    );
  }
}

class _SearchCommunitiesView extends StatefulWidget {
  final List<Group> groups;
  final String userId;

  const _SearchCommunitiesView({required this.groups, required this.userId});

  @override
  State<_SearchCommunitiesView> createState() => _SearchCommunitiesPageState();
}

class _SearchCommunitiesPageState extends State<_SearchCommunitiesView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String _selectedFilter = "All";

  final List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  List<String> _filters = ["All"];

  @override
  void initState() {
    super.initState();
    _extractTrendingAndFilters();
  }

  void _saveSearchTerm(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _recentSearches.removeWhere(
          (element) => element.toLowerCase() == trimmed.toLowerCase());
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
  }

  void _removeRecentSearch(String term) {
    setState(() {
      _recentSearches.remove(term);
    });
  }

  void _extractTrendingAndFilters() {
    final Set<String> extractedTags = {};

    for (var group in widget.groups) {
      final words = "${group.name} ${group.description}"
          .split(RegExp(r'[\s,._\-&]+'))
          .where((w) => w.length > 2)
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase());

      for (var word in words) {
        if (!['And', 'The', 'For', 'With', 'All', 'You', 'Club', 'Group']
            .contains(word)) {
          extractedTags.add(word);
        }
      }
    }

    final tagList = extractedTags.toList();

    setState(() {
      _trendingSearches = tagList.take(4).toList();
      _filters = ["All", ...tagList.take(6)];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToChat(BuildContext context, Group group) {
    Navigator.push(
      context,
      ChatPage.route(groupId: group.id, groupName: group.name),
    );
  }

  /// Joined -> leave (admins are redirected to the profile page),
  /// pending -> cancel request, otherwise join / request to join.
  /// Results are shown by the MembershipBloc listener in [build].
  void _handleGroupAction(Group group, bool isJoined, bool isPending) {
    final membership = context.read<MembershipBloc>();
    if (isJoined) {
      membership.add(MembershipLeavePressed(
        groupId: group.id,
        groupName: group.name,
        userId: widget.userId,
        blockIfAdmin: true,
      ));
    } else if (isPending) {
      membership.add(MembershipCancelRequestPressed(group, widget.userId));
    } else {
      membership.add(MembershipJoinPressed(group, widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = widget.groups.where((group) {
      final matchesQuery = group.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          group.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == "All" ||
          group.name.toLowerCase().contains(_selectedFilter.toLowerCase()) ||
          group.description
              .toLowerCase()
              .contains(_selectedFilter.toLowerCase());

      return matchesQuery && matchesFilter;
    }).toList();

    final membership = context.watch<MembershipBloc>().state;

    return BlocListener<MembershipBloc, MembershipState>(
      listenWhen: (p, c) => p.outcomeId != c.outcomeId,
      listener: (context, state) {
        final message = state.outcome!.message;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message.replaceAll('Exception: ', '')),
        ));
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Search Communities",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            // Search Input Field
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _saveSearchTerm(value),
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: "Communities, topics or keywords...",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Searches Section
            if (_recentSearches.isNotEmpty) ...[
              const Text(
                "Recent Searches",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches
                    .map((item) => _ChipWidget(
                          label: item,
                          assetPath: "assets/community/history.png",
                          fallbackIcon: Icons.history,
                          onTap: () {
                            _searchController.text = item;
                            setState(() => _searchQuery = item);
                            _saveSearchTerm(item);
                          },
                          onDelete: () => _removeRecentSearch(item),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Trending Searches Section
            if (_trendingSearches.isNotEmpty) ...[
              const Text(
                "Trending Searches",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _trendingSearches
                    .map((item) => _ChipWidget(
                          label: item,
                          assetPath: "assets/community/trend.png",
                          fallbackIcon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFF6366F1),
                          onTap: () {
                            _searchController.text = item;
                            setState(() {
                              _searchQuery = item;
                              _selectedFilter = "All";
                            });
                            _saveSearchTerm(item);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Filters Section
            Row(
              children: [
                Image.asset("assets/community/filter.png"),
                const SizedBox(width: 6),
                const Text(
                  "Filters",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected =
                      _selectedFilter.toLowerCase() == filter.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: const Color(0xFFEEF2FF),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF64748B),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                        ),
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),

            // Results Counter
            Text(
              "${filteredGroups.length} COMMUNITIES FOUND",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 12),

            // Communities List Items
            if (filteredGroups.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    "No communities found",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ),
              )
            else
              ...filteredGroups.map(
                (group) {
                  final isJoined = membership.isJoined(group.id);
                  final isPending = membership.isPending(group.id);

                  return _CommunityCardTile(
                    group: group,
                    isJoined: isJoined,
                    isPending: isPending,
                    activeFilter: _selectedFilter,
                    availableFilters: _filters,
                    onTap: () {
                      if (_searchQuery.isNotEmpty) {
                        _saveSearchTerm(_searchQuery);
                      }
                      if (isJoined) {
                        _navigateToChat(context, group);
                      } else {
                        _handleGroupAction(group, isJoined, isPending);
                      }
                    },
                    onToggleJoin: () =>
                        _handleGroupAction(group, isJoined, isPending),
                  );
                },
              ),
          ],
        ),
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Chip Component
// ---------------------------------------------------------------------------
class _ChipWidget extends StatelessWidget {
  final String label;
  final String assetPath;
  final IconData fallbackIcon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ChipWidget({
    required this.label,
    this.assetPath = "assets/community/trend.png",
    this.fallbackIcon = Icons.search,
    this.iconColor = const Color(0xFF64748B),
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetPath,
              width: 14,
              height: 14,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                size: 14,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Community Card Item Component
// ---------------------------------------------------------------------------
class _CommunityCardTile extends StatelessWidget {
  final Group group;
  final bool isJoined;
  final bool isPending;
  final String activeFilter;
  final List<String> availableFilters;
  final VoidCallback onTap;
  final VoidCallback onToggleJoin;

  const _CommunityCardTile({
    required this.group,
    required this.isJoined,
    required this.isPending,
    required this.activeFilter,
    required this.availableFilters,
    required this.onTap,
    required this.onToggleJoin,
  });

  String _determineCategoryTag() {
    if (activeFilter != "All") {
      return activeFilter;
    }

    final textToSearch = "${group.name} ${group.description}".toLowerCase();
    for (var filter in availableFilters) {
      if (filter != "All" && textToSearch.contains(filter.toLowerCase())) {
        return filter;
      }
    }

    return "General";
  }

  @override
  Widget build(BuildContext context) {
    final categoryTag = _determineCategoryTag();

    String buttonText = "Join";
    Color bgColor = Colors.white;
    Color fgColor = const Color(0xFF6366F1);
    BorderSide borderSide =
        const BorderSide(color: Color(0xFF6366F1), width: 1.5);

    if (isJoined) {
      buttonText = "✓ Joined";
      bgColor = const Color(0xFF6366F1);
      fgColor = Colors.white;
      borderSide = BorderSide.none;
    } else if (isPending) {
      buttonText = "Request Sent";
      bgColor = const Color(0xFFF1F5F9);
      fgColor = const Color(0xFF64748B);
      borderSide = BorderSide(color: Colors.grey.shade300, width: 1);
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Image Thumbnail
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                color: const Color(0xFFEEF2FF),
                child: group.imageUrl.trim().isNotEmpty
                    ? Image.network(
                        group.imageUrl.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.groups_rounded,
                          color: Color(0xFF6366F1),
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.groups_rounded,
                        color: Color(0xFF6366F1),
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Middle Column Content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom Stats Row
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Image.asset("assets/community/profile_icon_3.png"),
                        const SizedBox(width: 2),
                        Text(
                          "${group.memberCount} Members",
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Image.asset("assets/community/green_dot.png"),
                        const Text(
                          " 1 Online",
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 28),

                        // Dynamic Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            categoryTag,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6537F2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),

          // Dynamic Top-Right Action Button
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: onToggleJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: 0,
                side: borderSide,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
