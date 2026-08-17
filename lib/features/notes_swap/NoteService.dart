import 'package:cloud_firestore/cloud_firestore.dart';

class NoteService {
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');
  final CollectionReference alertsCollection =
      FirebaseFirestore.instance.collection('notifications');

  // Stream of all published notes (for Search & Feed)
  Stream<QuerySnapshot> getNotesStream({String? department}) {
    if (department != null && department.isNotEmpty && department != 'All') {
      return notesCollection
          .where('department', isEqualTo: department)
          .snapshots();
    }
    return notesCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // Stream of purchased notes
  Stream<QuerySnapshot> getPurchasedNotesStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bought_notes')
        .snapshots();
  }

  // Stream of general notifications
  Stream<QuerySnapshot> getNotificationsStream() {
    return alertsCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // Add a new note entry to Firebase Firestore
  Future<void> uploadNote({
    required String department,
    required String courseName,
    required String fileName,
    required double price,
    required bool isFree,
    required bool isPublic,
  }) async {
    await notesCollection.add({
      'department': department,
      'courseName': courseName,
      'fileName': fileName,
      'price': isFree ? 0 : price,
      'isFree': isFree,
      'isPublic': isPublic,
      'author': 'Current Student',
      'rating': 5.0,
      'downloads': 0,
      'createdAt': FieldValue.serverTimestamp(), // ✅ Correct Firestore method
    });
  }
}
