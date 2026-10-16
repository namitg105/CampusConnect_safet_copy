import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class NotificationBadgeRemoteDataSource {
  Stream<int> watchUnreadCount({required String uid, required String email});
}

class NotificationBadgeRemoteDataSourceImpl
    implements NotificationBadgeRemoteDataSource {
  final FirebaseFirestore firestore;
  const NotificationBadgeRemoteDataSourceImpl(this.firestore);

  @override
  Stream<int> watchUnreadCount({required String uid, required String email}) {
    final userEmail = email.toLowerCase().trim();
    final userDomain =
        userEmail.contains('@') ? userEmail.split('@').last : '';

    // NOTE: reads the whole collection and filters on the device, exactly
    // like the previous GetX controller. Fine for small data; should become
    // a server-side `where` query as notifications grow.
    return firestore.collection('notifications').snapshots().map(
          (snapshot) => snapshot.docs
              .where((doc) => isUnreadForUser(
                    doc.data(),
                    uid: uid,
                    userDomain: userDomain,
                  ))
              .length,
        );
  }

  /// A notification counts when it is unread and either addressed to the
  /// user directly, or (when it has no recipient) comes from the user's
  /// college — by sender email domain, else by `collegeId`.
  static bool isUnreadForUser(
    Map<String, dynamic> data, {
    required String uid,
    required String userDomain,
  }) {
    final isRead = data['isRead'] == true || data['isSeen'] == true;
    if (isRead) return false;

    final recipientId = data['recipientId'] as String?;
    if (recipientId != null && recipientId.isNotEmpty) {
      return recipientId == uid;
    }
    if (userDomain.isEmpty) return false;

    final senderEmail = (data['senderEmail'] as String?)?.toLowerCase().trim();
    if (senderEmail != null && senderEmail.contains('@')) {
      return senderEmail.split('@').last.trim() == userDomain;
    }
    final collegeId = (data['collegeId'] as String?)?.toLowerCase().trim();
    return collegeId != null && collegeId.isNotEmpty && collegeId == userDomain;
  }
}
