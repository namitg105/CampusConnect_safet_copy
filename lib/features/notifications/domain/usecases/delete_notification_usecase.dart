import '../repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase({required this.repository});

  Future<void> call(String notificationId) {
    return repository.deleteNotification(notificationId);
  }
}
