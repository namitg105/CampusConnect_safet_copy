import '../model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsSeen(String notificationId);
  Future<void> deleteNotification(String notificationId);
}
