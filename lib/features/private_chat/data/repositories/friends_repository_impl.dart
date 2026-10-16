import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remote;
  const FriendsRepositoryImpl(this.remote);

  @override
  Stream<Either<Failure, List<AppUser>>> watchFriends(String uid) =>
      guardStream(remote.watchFriends(uid));

  @override
  Stream<Either<Failure, Map<String, bool>>> watchOnlineStatuses(
          List<String> uids) =>
      guardStream(remote.watchOnlineStatuses(uids));

  @override
  Stream<Either<Failure, Set<String>>> watchBlockedUids(String uid) =>
      guardStream(remote.watchBlockedUids(uid));

  @override
  Stream<Either<Failure, List<FriendRequest>>> watchIncomingRequests(
          String uid) =>
      guardStream(remote.watchIncomingRequests(uid));

  @override
  Stream<Either<Failure, Set<String>>> watchSentRequestUids(String uid) =>
      guardStream(remote.watchSentRequestUids(uid));

  @override
  Stream<Either<Failure, List<FriendRequest>>> watchIgnoredRequests(
          String uid) =>
      guardStream(remote.watchIgnoredRequests(uid));

  @override
  Stream<Either<Failure, List<AppUser>>> watchDirectory(String uid) =>
      guardStream(remote.watchDirectory(uid));

  @override
  Future<Either<Failure, void>> sendFriendRequest(String targetUid) =>
      guardFuture(() => remote.sendFriendRequest(targetUid));

  @override
  Future<Either<Failure, String>> acceptRequest(String requesterUid) =>
      guardFuture(() => remote.acceptRequest(requesterUid));

  @override
  Future<Either<Failure, String>> declineRequest(String requesterUid) =>
      guardFuture(() => remote.declineRequest(requesterUid));

  @override
  Future<Either<Failure, String>> acceptIgnoredRequest(String requesterUid) =>
      guardFuture(() => remote.acceptIgnoredRequest(requesterUid));

  @override
  Future<Either<Failure, void>> blockUser(String targetUid) =>
      guardFuture(() => remote.blockUser(targetUid));

  @override
  Future<Either<Failure, void>> unblockUser(String targetUid) =>
      guardFuture(() => remote.unblockUser(targetUid));
}
