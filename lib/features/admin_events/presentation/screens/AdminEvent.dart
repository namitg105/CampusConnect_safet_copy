import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../community/Widgets/community_page.dart';
import '../../../events/domain/entities/event.dart';

// ==================== DESIGN TOKENS ====================
const Color _brandPrimary = Color(0xFF6366F1);
const Color _primaryPurple = Color(0xFF6C38FF);
const Color _lightPurpleBg = Color(0xFFF7F5FF);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _bgSurface = Color(0xFFF8FAFC);
const Color _borderColor = Color(0xFFEBEBF0);

class AllCommunityEventsPage extends StatefulWidget {
  const AllCommunityEventsPage({super.key});

  @override
  State<AllCommunityEventsPage> createState() => _AllCommunityEventsPageState();
}

class _AllCommunityEventsPageState extends State<AllCommunityEventsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Active', 'Cancelled'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'All Community Events',
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH & FILTER BAR
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Search Input
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: _textMuted, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val.trim()),
                            decoration: const InputDecoration(
                              hintText:
                                  'Search events by title, description or venue...',
                              hintStyle:
                                  TextStyle(fontSize: 12, color: _textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style:
                                const TextStyle(fontSize: 13, color: _textDark),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close,
                                color: _textMuted, size: 18),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled'),
                    ],
                  ),
                ],
              ),
            ),

            // REAL-TIME FIRESTORE EVENTS FEED
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('events').snapshots(),
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
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No community events found.",
                        style: TextStyle(color: _textMuted, fontSize: 13),
                      ),
                    );
                  }

                  // Map Firestore raw documents into typed models & filter by status
                  final allEvents = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? 'active').toString();

                    if (_selectedFilter == 'Active') {
                      return status != 'cancelled';
                    } else if (_selectedFilter == 'Cancelled') {
                      return status == 'cancelled';
                    }
                    return true;
                  }).map((doc) {
                    return Event.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );
                  }).toList();

                  // Sort chronologically by event date
                  allEvents.sort((a, b) => a.date.compareTo(b.date));

                  // Apply text search query
                  final filteredEvents = allEvents.where((e) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return e.title.toLowerCase().contains(q) ||
                        e.description.toLowerCase().contains(q) ||
                        e.location.toLowerCase().contains(q);
                  }).toList();

                  if (filteredEvents.isEmpty) {
                    return const Center(
                      child: Text(
                        "No events match your criteria.",
                        style: TextStyle(color: _textMuted, fontSize: 13),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _AllEventsCard(event: event);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _brandPrimary : _bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _brandPrimary : _borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : _textMuted,
          ),
        ),
      ),
    );
  }
}

// ==================== EVENT LIST ITEM CARD ====================

class _AllEventsCard extends StatelessWidget {
  final Event event;

  const _AllEventsCard({required this.event});

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          event: event,
          groupId: event.groupId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = event.date;
    final String month = DateFormat('MMM').format(date).toUpperCase();
    final String day = DateFormat('dd').format(date);
    final String weekday = DateFormat('EEE').format(date).toUpperCase();
    final String timeStr = DateFormat('h:mm a').format(date);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .snapshots(),
      builder: (context, snapshot) {
        int filledSpots = event.filledSpots;
        bool isCancelled = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          filledSpots = data?['filledSpots'] ?? filledSpots;
          isCancelled = data?['status'] == 'cancelled';
        }

        return GestureDetector(
          onTap: () => _navigateToDetails(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCancelled ? const Color(0xFFFFF5F5) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCancelled ? Colors.red.shade200 : _borderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Badge
                Container(
                  width: 44,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isCancelled ? Colors.red.shade50 : _lightPurpleBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color:
                              isCancelled ? Colors.redAccent : _primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCancelled ? Colors.red.shade900 : _textDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color:
                              isCancelled ? Colors.redAccent : _primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Event Main Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCancelled
                                    ? Colors.red.shade900
                                    : _textDark,
                                decoration: isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (isCancelled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CANCELLED',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCancelled
                            ? "This event has been cancelled."
                            : (event.description.isNotEmpty
                                ? event.description
                                : "No description"),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isCancelled ? Colors.redAccent : _textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: _textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              event.location.isNotEmpty
                                  ? event.location
                                  : 'Online / TBD',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time,
                              size: 12, color: _textMuted),
                          const SizedBox(width: 3),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Column / Attendees
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _lightPurpleBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "+$filledSpots going",
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
