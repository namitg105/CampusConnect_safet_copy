import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/friend_request.dart';

/// Friends, friend requests, blocking and the people directory.
abstract interface class FriendsRepository {
  Stream<Either<Failure, List<AppUser>>> watchFriends(String uid);

  /// uid -> online, for the given users (any number of them).
  Stream<Either<Failure, Map<String, bool>>> watchOnlineStatuses(
      List<String> uids);

  Stream<Either<Failure, Set<String>>> watchBlockedUids(String uid);

  /// Pending requests other people sent to [uid].
  Stream<Either<Failure, List<FriendRequest>>> watchIncomingRequests(
      String uid);

  /// Uids [uid] has sent a pending request to.
  Stream<Either<Failure, Set<String>>> watchSentRequestUids(String uid);

  Stream<Either<Failure, List<FriendRequest>>> watchIgnoredRequests(
      String uid);

  /// Every other user of the app.
  Stream<Either<Failure, List<AppUser>>> watchDirectory(String uid);

  Future<Either<Failure, void>> sendFriendRequest(String targetUid);

  /// Returns the new friend's current name.
  Future<Either<Failure, String>> acceptRequest(String requesterUid);

  /// Marks the request as ignored. Returns the requester's current name.
  Future<Either<Failure, String>> declineRequest(String requesterUid);

  /// Accepts a previously ignored request. Returns the new friend's name.
  Future<Either<Failure, String>> acceptIgnoredRequest(String requesterUid);

  Future<Either<Failure, void>> blockUser(String targetUid);

  Future<Either<Failure, void>> unblockUser(String targetUid);
}
