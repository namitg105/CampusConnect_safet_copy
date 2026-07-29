import '../model.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  Stream<List<NotificationModel>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
