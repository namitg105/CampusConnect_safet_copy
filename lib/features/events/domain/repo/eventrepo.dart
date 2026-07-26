import 'package:cloud_firestore/cloud_firestore.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Fetch live event details stream
  Stream<DocumentSnapshot> streamEventDetails(String eventId) {
    return _firestore.collection('events').doc(eventId).snapshots();
  }

  Future<void> rsvpToEvent({
    required String eventId,
    required String userId,
    required String userEmail,
  }) async {
    final DocumentReference eventRef =
        _firestore.collection('events').doc(eventId);
    final DocumentReference userRsvpRef =
        eventRef.collection('rsvps').doc(userId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot eventSnapshot = await transaction.get(eventRef);

      if (!eventSnapshot.exists) {
        throw Exception("Event does not exist!");
      }

      // SAFE EXTRACTION: Use data map checking to prevent the missing field crash
      final Map<String, dynamic> data =
          eventSnapshot.data() as Map<String, dynamic>;

      int currentFilled = data['filledSpots'] ?? 0;
      int maxSpots = data['maxSpots'] ?? 100;

      // Safely look up list or initialize a clean empty array fallback
      List<dynamic> attendees =
          data.containsKey('attendees') && data['attendees'] != null
              ? List.from(data['attendees'])
              : [];

      if (attendees.contains(userId)) {
        throw Exception("You have already joined this event!");
      }

      if (currentFilled >= maxSpots) {
        throw Exception("Event is fully booked!");
      }

      // Update the base event metrics (creates 'attendees' automatically if missing)
      transaction.update(eventRef, {
        'filledSpots': currentFilled + 1,
        'attendees': FieldValue.arrayUnion([userId]),
      });

      // Save user metadata inside subcollection
      transaction.set(userRsvpRef, {
        'userId': userId,
        'email': userEmail,
        'rsvpAt': Timestamp.now(),
      });
    });
  }
}
