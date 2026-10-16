import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_badge_repository.dart';

class WatchUnreadCount implements StreamUseCase<int, WatchUnreadCountParams> {
  final NotificationBadgeRepository repository;
  const WatchUnreadCount(this.repository);

  @override
  Stream<Either<Failure, int>> call(WatchUnreadCountParams params) {
    return repository.watchUnreadCount(uid: params.uid, email: params.email);
  }
}

class WatchUnreadCountParams {
  final String uid;
  final String email;
  const WatchUnreadCountParams({required this.uid, required this.email});
}
