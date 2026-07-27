import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_states.dart';
import '../../../events/domain/repo/eventrepo.dart';
import 'admin_ticket.dart';

class EventDetailsPage extends StatelessWidget {
  final EventRepository _eventRepo = EventRepository();

  EventDetailsPage({Key? key}) : super(key: key);

  /// Helper to safely handle String or Firestore Timestamp date values
  String _formatDateField(dynamic value, String fallback) {
    if (value is String && value.isNotEmpty) {
      return value;
    } else if (value is Timestamp) {
      DateTime dt = value.toDate();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    // Dummy user fallback values for testing
    const String dummyUserId = "dummy_user_12345";
    const String dummyUserEmail = "dummy.student@vit.ac.in";

    final authState = context.read<AuthCubit>().state;
    String currentUserId = dummyUserId;
    String currentUserEmail = dummyUserEmail;

    if (authState is Authenticated) {
      currentUserId = authState.user.uid;
      currentUserEmail = authState.user.email ?? dummyUserEmail;
      print(
          "DEBUG [Auth]: User is authenticated. UID: $currentUserId, Email: $currentUserEmail");
    } else {
      print(
          "DEBUG [Auth]: User is NOT authenticated. AuthState is: $authState");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("DEBUG [Firestore Error]: ${snapshot.error}");
          }

          // Complete dummy data set used whenever fields or collection are missing
          Map<String, dynamic> dummyEventData = {
            'title': 'Tech Symposium 2026',
            'date': 'Oct 24, 2026',
            'dateSubtitle': 'Saturday, 10:00 AM',
            'time': '10:00 AM - 04:00 PM',
            'timeSubtitle': 'GMT+5:30',
            'venue': 'Anna Auditorium, VIT',
            'venueSubtitle': 'Main Campus, Vellore',
            'about':
                'Join us for the annual university Tech Symposium! Experience keynote speeches, interactive workshops, live demo presentations, and networking opportunities with tech leaders.',
            'filledSpots': 42,
            'maxSpots': 100,
            'audience': 'All Engineering Students',
            'audienceSubtitle': 'Open to Year 1-4',
            'imageUrl':
                'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
            'participants': ['dummy_user_12345', 'user_abc', 'user_xyz'],
            'schedule': [
              {'title': 'Opening Keynote', 'time': '10:00 AM'},
              {'title': 'AI & Robotics Workshop', 'time': '11:30 AM'},
              {'title': 'Networking Lunch', 'time': '01:00 PM'},
              {'title': 'Hackathon Demos', 'time': '02:30 PM'},
            ],
            'tags': [
              {"label": "🎶 Event", "type": "purple"},
              {"label": "💸 Free Entry", "type": "green"},
              {"label": "🎂 All Years", "type": "orange"}
            ]
          };

          String dynamicEventId = "dummy_event_999";
          Map<String, dynamic> eventData = dummyEventData;

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var eventDoc = snapshot.data!.docs.first;
            dynamicEventId = eventDoc.id;
            eventData = eventDoc.data() as Map<String, dynamic>;
            print(
                "DEBUG [Firestore Data Fetched]: Found document ID: $dynamicEventId");
          }

          String title = eventData['title'] ?? dummyEventData['title'];
          String dateTitle =
              _formatDateField(eventData['date'], dummyEventData['date']);
          String timeTitle =
              _formatDateField(eventData['time'], dummyEventData['time']);
          String venueTitle = eventData['venue'] ?? dummyEventData['venue'];
          String aboutText = eventData['about'] ?? dummyEventData['about'];

          int filledSpots =
              eventData['filledSpots'] ?? dummyEventData['filledSpots'];
          int maxSpots = eventData['maxSpots'] ?? dummyEventData['maxSpots'];
          List<dynamic> schedule =
              eventData['schedule'] ?? dummyEventData['schedule'];

          List<dynamic> participants =
              eventData['participants'] ?? dummyEventData['participants'];
          bool hasJoined =
              currentUserId.isNotEmpty && participants.contains(currentUserId);

          print(
              "DEBUG [RSVP State]: Field 'participants' contains: $participants");
          print("DEBUG [RSVP State]: Evaluation -> hasJoined = $hasJoined");

          List<dynamic> tagsData = eventData['tags'] ?? dummyEventData['tags'];

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220.0,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: const Padding(padding: EdgeInsets.all(8.0)),
                    actions: [
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black38,
                        child: IconButton(
                          icon: const Icon(Icons.share,
                              color: Colors.white, size: 18),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            eventData['imageUrl'] ?? dummyEventData['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 40,
                            left: 16,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.local_fire_department,
                                          color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text("SELLING FAST",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 12),
                                      SizedBox(width: 4),
                                      Text("Featured",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      transform: Matrix4.translationValues(0.0, -24.0, 0.0),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 120.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 32,
                                height: 3,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundImage: NetworkImage(
                                      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("VIT UNIVERSITY EVENTS",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple[400],
                                              fontSize: 13)),
                                      const Text("Verified organizer",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: tagsData.map((tagItem) {
                                String label = tagItem['label'] ?? 'Tag';
                                String colorType = tagItem['type'] ?? 'purple';
                                Color bgColor = Colors.purple[50]!;
                                Color textColor = Colors.purple[700]!;

                                if (colorType == 'green') {
                                  bgColor = Colors.green[50]!;
                                  textColor = Colors.green[700]!;
                                } else if (colorType == 'orange') {
                                  bgColor = Colors.orange[50]!;
                                  textColor = Colors.orange[700]!;
                                } else if (colorType == 'blue') {
                                  bgColor = Colors.blue[50]!;
                                  textColor = Colors.blue[700]!;
                                }
                                return _buildTag(label, bgColor, textColor);
                              }).toList(),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTabItem("About", isActive: true)
                              ],
                            ),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 18),
                            _buildInfoRow(
                                Icons.calendar_today,
                                Colors.purple[50]!,
                                "Date",
                                dateTitle,
                                eventData['dateSubtitle'] ??
                                    dummyEventData['dateSubtitle'],
                                actionText: "Remind"),
                            _buildInfoRow(
                                Icons.access_time,
                                Colors.amber[50]!,
                                "Time",
                                timeTitle,
                                eventData['timeSubtitle'] ??
                                    dummyEventData['timeSubtitle']),
                            _buildInfoRow(
                                Icons.location_on_outlined,
                                Colors.green[50]!,
                                "Venue",
                                venueTitle,
                                eventData['venueSubtitle'] ??
                                    dummyEventData['venueSubtitle'],
                                actionText: "Directions"),
                            _buildInfoRow(
                                Icons.assignment_ind_outlined,
                                Colors.blue[50]!,
                                "Audience",
                                eventData['audience'] ??
                                    dummyEventData['audience'],
                                eventData['audienceSubtitle'] ??
                                    dummyEventData['audienceSubtitle']),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.purple[50]!.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.people_outline,
                                          color: Colors.deepPurple, size: 18),
                                      const SizedBox(width: 6),
                                      const Text("Participants",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.zero),
                                        child: Row(
                                          children: [
                                            Text("See all",
                                                style: TextStyle(
                                                    color:
                                                        Colors.deepPurple[400],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11)),
                                            Icon(Icons.chevron_right,
                                                color: Colors.deepPurple[400],
                                                size: 14),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        height: 24,
                                        child: Stack(
                                          children: List.generate(4, (index) {
                                            return Positioned(
                                              left: index * 14.0,
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.white,
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: NetworkImage(
                                                      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&index=$index'),
                                                ),
                                              ),
                                            );
                                          })
                                            ..add(
                                              Positioned(
                                                left: 4 * 14.0,
                                                child: CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      Colors.deepPurple[400],
                                                  child: Text(
                                                      filledSpots > 4
                                                          ? "+${filledSpots - 4}"
                                                          : "+0",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                            ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("$filledSpots attending",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                          const Text(
                                              "Students & friends registered",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10)),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Capacity",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10)),
                                      Text(
                                          "$filledSpots/$maxSpots spots filled",
                                          style: TextStyle(
                                              color: Colors.redAccent[400],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: maxSpots > 0
                                          ? (filledSpots / maxSpots)
                                          : 0.0,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.deepPurple[400]!),
                                      minHeight: 5,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text("About this Event",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(aboutText,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    height: 1.4,
                                    fontSize: 13)),
                            const SizedBox(height: 20),
                            if (schedule.isNotEmpty) ...[
                              const Text("Schedule Info",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...schedule.map((item) {
                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  color: Colors.grey[50],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(Icons.circle,
                                        color: Colors.deepPurple[300],
                                        size: 10),
                                    title: Text(item['title'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    trailing: Text(item['time'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 11)),
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 12.0, bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, -4))
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton.icon(
                      onPressed: (currentUserId.isEmpty)
                          ? null
                          : () async {
                              print(
                                  "DEBUG [Button Press]: Action initiated. hasJoined = $hasJoined");

                              String safeEventId = dynamicEventId.length > 4
                                  ? dynamicEventId.substring(0, 4)
                                  : dynamicEventId;
                              String safeUserId = currentUserId.length > 4
                                  ? currentUserId.substring(0, 4)
                                  : currentUserId;
                              String calculatedTicketId =
                                  "${safeEventId}-${safeUserId}".toUpperCase();

                              if (hasJoined) {
                                print(
                                    "DEBUG [Navigation]: Pushing to AdminTicketPage directly.");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminTicketPage(
                                      eventTitle: title,
                                      eventDate: dateTitle,
                                      eventTime: timeTitle,
                                      eventVenue: venueTitle,
                                      userEmail: currentUserEmail,
                                      ticketId: calculatedTicketId,
                                    ),
                                  ),
                                );
                              } else {
                                try {
                                  print(
                                      "DEBUG [RSVP Flow]: Invoking _eventRepo.rsvpToEvent...");
                                  await _eventRepo.rsvpToEvent(
                                    eventId: dynamicEventId,
                                    userId: currentUserId,
                                    userEmail: currentUserEmail,
                                  );

                                  print(
                                      "DEBUG [RSVP Flow]: Firestore write complete. Redirecting to Ticket.");

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "RSVP Registered Successfully!")),
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminTicketPage(
                                        eventTitle: title,
                                        eventDate: dateTitle,
                                        eventTime: timeTitle,
                                        eventVenue: venueTitle,
                                        userEmail: currentUserEmail,
                                        ticketId: calculatedTicketId,
                                      ),
                                    ),
                                  );
                                } catch (e, stacktrace) {
                                  print("DEBUG [RSVP Exception Caught]: $e");
                                  print("STACKTRACE: $stacktrace");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(e
                                            .toString()
                                            .replaceAll("Exception: ", ""))),
                                  );
                                }
                              }
                            },
                      icon: Icon(
                        hasJoined
                            ? Icons.confirmation_number
                            : Icons.confirmation_number_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        hasJoined ? "VIEW TICKET" : "JOIN NOW",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasJoined
                            ? const Color(0xFF00E676)
                            : const Color(0xFF7C4DFF),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Text(label,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w600, fontSize: 11)));
  }

  Widget _buildTabItem(String title, {bool isActive = false}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF7C4DFF) : Colors.grey)),
            const SizedBox(height: 4),
            if (isActive)
              Container(width: 36, height: 2, color: const Color(0xFF7C4DFF))
          ],
        ));
  }

  Widget _buildInfoRow(IconData icon, Color iconBg, String fieldLabel,
      String title, String subtitle,
      {String? actionText}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
              backgroundColor: iconBg,
              radius: 16,
              child: Icon(icon, color: const Color(0xFF7C4DFF), size: 16)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(fieldLabel,
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 1),
                Text(title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11))
              ])),
          if (actionText != null)
            TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    backgroundColor: Colors.purple[50],
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                child: Text(actionText,
                    style: const TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)))
        ]));
  }
}
