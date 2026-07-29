import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/model.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', whereIn: [userId, 'all'])
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => NotificationModel.fromDoc(doc))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  @override
  Future<void> markAsSeen(String notificationId) {
    return _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isSeen': true});
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _firestore.collection('notifications').doc(notificationId).delete();
  }
}
