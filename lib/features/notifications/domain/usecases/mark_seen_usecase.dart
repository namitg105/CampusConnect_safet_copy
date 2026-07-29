import '../repositories/notification_repository.dart';

class MarkNotificationAsSeenUseCase {
  final NotificationRepository repository;

  MarkNotificationAsSeenUseCase({required this.repository});

  Future<void> call(String notificationId) {
    return repository.markAsSeen(notificationId);
  }
}
