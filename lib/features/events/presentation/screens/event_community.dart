import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart' as entity;

// ==================== DESIGN TOKENS ====================

const Color _primaryPurple = Color(0xFF6D4CFF);
const Color _lightPurpleBg = Color(0xFFF7F5FF);
const Color _cardBgColor = Color(0xFFF9F8FD);
const Color _primaryText = Color(0xFF1E1F24);
const Color _secondaryText = Color(0xFF6E717C);
const Color _borderColor = Color(0xFFEBEBF0);


class UpcomingEventsSection extends StatefulWidget {
  final String groupId;
  final bool isCurrentUserAdmin;

  const UpcomingEventsSection(
    {
  super.key,
    required this.groupId,
    required this.isCurrentUserAdmin,
  }
  );

  @override
  State<UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- SHOW CREATE EVENT MODAL WITH DATE/TIME PICKER ---
  void _showCreateEventModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final categoryController = TextEditingController(text: 'Workshop');
    final formatController = TextEditingController(text: 'Hybrid event');
    final speakerNameController = TextEditingController();
    final speakerDescController = TextEditingController();

    DateTime selectedDateTime = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Create Group Event",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Event Title *",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location / Venue",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // DATE AND TIME PICKER TILE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Event Date & Time",
                                style: TextStyle(
                                    fontSize: 11, color: _secondaryText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEE, MMM dd, yyyy - hh:mm a')
                                    .format(selectedDateTime),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryText,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month,
                                size: 18, color: _primaryPurple),
                            label: const Text(
                              "Change",
                              style: TextStyle(
                                  color: _primaryPurple,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date == null) return;

                              if (!context.mounted) return;
                              final time = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(selectedDateTime),
                              );
                              if (time == null) return;

                              setModalState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: "Category",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: formatController,
                            decoration: const InputDecoration(
                              labelText: "Format (e.g. Offline)",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: speakerNameController,
                      decoration: const InputDecoration(
                        labelText: "Speaker Name (Optional)",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: speakerDescController,
                      decoration: const InputDecoration(
                        labelText: "Speaker Bio / Description (Optional)",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter an event title")),
                            );
                            return;
                          }

                          final uid =
                              FirebaseAuth.instance.currentUser?.uid ?? '';

                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(widget.groupId)
                              .collection('events')
                              .add({
                            'title': titleController.text.trim(),
                            'description': descController.text.trim(),
                            'location': locationController.text.trim(),
                            'date': Timestamp.fromDate(selectedDateTime),
                            'category': categoryController.text.trim(),
                            'format': formatController.text.trim(),
                            'speakerName': speakerNameController.text.trim(),
                            'speakerDescription':
                                speakerDescController.text.trim(),
                            'createdBy': uid,
                            'createdAt': FieldValue.serverTimestamp(),
                            'filledSpots': 0,
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Event created successfully!"),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Publish Event",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('events')
          .doc(eventId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event deleted successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete event: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPad = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFilterBar(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          onFilterTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (widget.isCurrentUserAdmin)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _showCreateEventModal,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    "Create Event",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('events')
                .orderBy('date', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primaryPurple,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No upcoming events found for this group.",
                    style: TextStyle(color: _secondaryText, fontSize: 12),
                  ),
                );
              }

              final eventsList = snapshot.data!.docs.map((doc) {
                return entity.Event.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

              final filteredEvents = eventsList.where((e) {
                if (_searchQuery.isEmpty) return true;
                final query = _searchQuery.toLowerCase();
                return e.title.toLowerCase().contains(query) ||
                    e.description.toLowerCase().contains(query) ||
                    e.location.toLowerCase().contains(query);
              }).toList();

              if (filteredEvents.isEmpty) {
                return const Center(
                  child: Text(
                    "No matching events found",
                    style: TextStyle(color: _secondaryText, fontSize: 12),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: verticalPad,
                ),
                itemCount: filteredEvents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final eventData = filteredEvents[index];
                  return DynamicEventCard(
                    event: eventData,
                    groupId: widget.groupId,
                    isCurrentUserAdmin: widget.isCurrentUserAdmin,
                    onDelete: () => _deleteEvent(eventData.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== 2. LIST SECTION SUB-COMPONENTS ====================

class SearchFilterBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const SearchFilterBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    const double barH = 36.0;
    const double filterSize = 36.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: barH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.search, color: _secondaryText, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search group events....',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: filterSize,
              height: filterSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor, width: 1),
              ),
              child: const Icon(
                Icons.filter_alt_outlined,
                color: _primaryPurple,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDateBadge extends StatelessWidget {
  final String month;
  final String day;
  final String weekday;

  const EventDateBadge({
    super.key,
    required this.month,
    required this.day,
    required this.weekday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 52,
      decoration: BoxDecoration(
        color: _lightPurpleBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            day,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            weekday,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: _primaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  final bool isLoading;
  final bool isRegistered;
  final VoidCallback? onPressed;

  const RegisterButton({
    super.key,
    this.isLoading = false,
    this.isRegistered = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 28,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRegistered ? Colors.green : _primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRegistered) ...[
                      const Icon(Icons.check, size: 12),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      isRegistered ? 'Going' : 'Register',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class EventMetadataRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const EventMetadataRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _secondaryText),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== 3. DYNAMIC EVENT CARD ====================

class DynamicEventCard extends StatefulWidget {
  final entity.Event event;
  final String groupId;
  final bool isCurrentUserAdmin;
  final VoidCallback onDelete;

  const DynamicEventCard({
    super.key,
    required this.event,
    required this.groupId,
    required this.isCurrentUserAdmin,
    required this.onDelete,
  });

  @override
  State<DynamicEventCard> createState() => _DynamicEventCardState();
}

class _DynamicEventCardState extends State<DynamicEventCard> {
  bool _isRegistering = false;

  Future<void> _handleRSVP() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isRegistering = true);

    try {
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

      final eventDocRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('events')
          .doc(widget.event.id);

      final rsvpRef = eventDocRef.collection('rsvps').doc(user.uid);

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

  void _navigateToDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          event: widget.event,
          groupId: widget.groupId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final DateTime date = widget.event.date;
    final String month = DateFormat('MMM').format(date).toUpperCase();
    final String day = DateFormat('dd').format(date);
    final String weekday = DateFormat('EEE').format(date).toUpperCase();
    final String timeStr = DateFormat('h:mm a').format(date);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('events')
          .doc(widget.event.id)
          .snapshots(),
      builder: (context, eventSnapshot) {
        int filledSpots = 0;
        if (eventSnapshot.hasData && eventSnapshot.data!.exists) {
          final data = eventSnapshot.data!.data() as Map<String, dynamic>?;
          filledSpots = data?['filledSpots'] ?? 0;
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: currentUser != null
              ? FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('events')
                  .doc(widget.event.id)
                  .collection('rsvps')
                  .doc(currentUser.uid)
                  .snapshots()
              : null,
          builder: (context, rsvpSnapshot) {
            final isRegistered =
                rsvpSnapshot.hasData && rsvpSnapshot.data!.exists;

            return GestureDetector(
              onTap: _navigateToDetails,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 56,
                        color: _lightPurpleBg,
                        child: const Icon(
                          Icons.event,
                          color: _primaryPurple,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    EventDateBadge(
                      month: month,
                      day: day,
                      weekday: weekday,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.event.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          EventMetadataRow(
                            icon: Icons.location_on_outlined,
                            text: widget.event.location,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            RegisterButton(
                              isLoading: _isRegistering,
                              isRegistered: isRegistered,
                              onPressed: () async {
                                if (isRegistered) {
                                  _navigateToDetails();
                                } else {
                                  await _handleRSVP();
                                  if (mounted) _navigateToDetails();
                                }
                              },
                            ),
                            if (widget.isCurrentUserAdmin) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onDelete,
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+$filledSpots interested',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: _primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== 4. EVENT DETAILS SCREEN ====================

class EventDetailsScreen extends StatefulWidget {
  final entity.Event event;
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
      final eventDocRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('events')
          .doc(widget.event.id);

      final rsvpRef = eventDocRef.collection('rsvps').doc(user.uid);

      if (isCurrentlyRegistered) {
        // UNREGISTER / CANCEL RSVP
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
        // REGISTER FOR EVENT
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            EventDetailsHeader(onBack: () => Navigator.of(context).pop()),
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
                    StreamBuilder<DocumentSnapshot>(
                      stream: user != null
                          ? FirebaseFirestore.instance
                              .collection('groups')
                              .doc(widget.groupId)
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
                          onCalendar: () {},
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    EventInfoGridHorizontal(
                      dateStr: DateFormat('MMM dd, yyyy').format(eventDate),
                      weekdayStr: DateFormat('EEEE').format(eventDate),
                      timeStr:
                          DateFormat('h.mm a').format(eventDate).toUpperCase(),
                      venue: widget.event.location,
                      format: widget.event.format ?? 'Hybrid event',
                    ),
                    const SizedBox(height: 16),
                    AboutEventCard(
                      description: widget.event.description,
                    ),
                    const SizedBox(height: 12),
                    SpeakerCard(
                      speakerName: widget.event.speakerName ?? 'Guest Speaker',
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
  }
}

// ==================== 5. DETAILS PAGE COMPONENTS ====================

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
              icon: const Icon(Icons.arrow_back, color: _primaryText, size: 24),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
          const Text(
            'Event Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class EventHeroBanner extends StatelessWidget {
  final entity.Event event;

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
                const Icon(
                  Icons.bookmark_border_rounded,
                  color: Colors.white,
                  size: 22,
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
            style: const TextStyle(fontSize: 10, color: _secondaryText),
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
              color: _primaryText,
            ),
          ),
          if (val2 != null)
            Text(
              val2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _primaryText,
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
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: _secondaryText,
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
              color: _primaryText,
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
                        color: _primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      speakerDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _secondaryText,
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
          .collection('groups')
          .doc(groupId)
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
