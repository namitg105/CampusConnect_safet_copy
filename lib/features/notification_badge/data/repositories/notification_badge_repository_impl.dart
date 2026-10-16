import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/repositories/notification_badge_repository.dart';
import '../datasources/notification_badge_remote_data_source.dart';

class NotificationBadgeRepositoryImpl implements NotificationBadgeRepository {
  final NotificationBadgeRemoteDataSource remoteDataSource;
  const NotificationBadgeRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, int>> watchUnreadCount({
    required String uid,
    required String email,
  }) {
    return guardStream(
      remoteDataSource.watchUnreadCount(uid: uid, email: email),
    );
  }
}
