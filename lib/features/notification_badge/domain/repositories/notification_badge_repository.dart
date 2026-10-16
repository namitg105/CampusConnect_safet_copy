import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class NotificationBadgeRepository {
  /// Live count of unread notifications meant for this user.
  Stream<Either<Failure, int>> watchUnreadCount({
    required String uid,
    required String email,
  });
}
