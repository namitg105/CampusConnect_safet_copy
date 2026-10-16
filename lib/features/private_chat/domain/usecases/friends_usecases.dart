import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/friend_request.dart';
import '../repositories/friends_repository.dart';
import '../repositories/private_chat_repository.dart';

// Live data (params: the current user's uid unless noted).

class WatchFriends implements StreamUseCase<List<AppUser>, String> {
  final FriendsRepository repo;
  const WatchFriends(this.repo);
  @override
  Stream<Either<Failure, List<AppUser>>> call(String uid) =>
      repo.watchFriends(uid);
}

/// Params: the uids to watch.
class WatchOnlineStatuses
    implements StreamUseCase<Map<String, bool>, List<String>> {
  final FriendsRepository repo;
  const WatchOnlineStatuses(this.repo);
  @override
  Stream<Either<Failure, Map<String, bool>>> call(List<String> uids) =>
      repo.watchOnlineStatuses(uids);
}

class WatchBlockedUids implements StreamUseCase<Set<String>, String> {
  final FriendsRepository repo;
  const WatchBlockedUids(this.repo);
  @override
  Stream<Either<Failure, Set<String>>> call(String uid) =>
      repo.watchBlockedUids(uid);
}

class WatchIncomingRequests
    implements StreamUseCase<List<FriendRequest>, String> {
  final FriendsRepository repo;
  const WatchIncomingRequests(this.repo);
  @override
  Stream<Either<Failure, List<FriendRequest>>> call(String uid) =>
      repo.watchIncomingRequests(uid);
}

class WatchSentRequestUids implements StreamUseCase<Set<String>, String> {
  final FriendsRepository repo;
  const WatchSentRequestUids(this.repo);
  @override
  Stream<Either<Failure, Set<String>>> call(String uid) =>
      repo.watchSentRequestUids(uid);
}

class WatchIgnoredRequests
    implements StreamUseCase<List<FriendRequest>, String> {
  final FriendsRepository repo;
  const WatchIgnoredRequests(this.repo);
  @override
  Stream<Either<Failure, List<FriendRequest>>> call(String uid) =>
      repo.watchIgnoredRequests(uid);
}

class WatchDirectory implements StreamUseCase<List<AppUser>, String> {
  final FriendsRepository repo;
  const WatchDirectory(this.repo);
  @override
  Stream<Either<Failure, List<AppUser>>> call(String uid) =>
      repo.watchDirectory(uid);
}

// Actions (params: the other user's uid).

class SendFriendRequest implements UseCase<void, String> {
  final FriendsRepository repo;
  const SendFriendRequest(this.repo);
  @override
  Future<Either<Failure, void>> call(String targetUid) =>
      repo.sendFriendRequest(targetUid);
}

/// Returns the new friend's name.
class AcceptFriendRequest implements UseCase<String, String> {
  final FriendsRepository repo;
  const AcceptFriendRequest(this.repo);
  @override
  Future<Either<Failure, String>> call(String requesterUid) =>
      repo.acceptRequest(requesterUid);
}

/// Returns the requester's name.
class DeclineFriendRequest implements UseCase<String, String> {
  final FriendsRepository repo;
  const DeclineFriendRequest(this.repo);
  @override
  Future<Either<Failure, String>> call(String requesterUid) =>
      repo.declineRequest(requesterUid);
}

/// Returns the new friend's name.
class AcceptIgnoredRequest implements UseCase<String, String> {
  final FriendsRepository repo;
  const AcceptIgnoredRequest(this.repo);
  @override
  Future<Either<Failure, String>> call(String requesterUid) =>
      repo.acceptIgnoredRequest(requesterUid);
}

class BlockUser implements UseCase<void, String> {
  final FriendsRepository repo;
  const BlockUser(this.repo);
  @override
  Future<Either<Failure, void>> call(String targetUid) =>
      repo.blockUser(targetUid);
}

class UnblockParams {
  final String targetUid;
  final String roomId;
  const UnblockParams({required this.targetUid, required this.roomId});
}

/// Unblocks the user, then marks their messages in the shared room as read
/// (same as before the refactor: messages sent while blocked are cleared).
class UnblockUser implements UseCase<void, UnblockParams> {
  final FriendsRepository friends;
  final PrivateChatRepository chat;
  const UnblockUser({required this.friends, required this.chat});
  @override
  Future<Either<Failure, void>> call(UnblockParams p) async {
    final result = await friends.unblockUser(p.targetUid);
    if (result.isLeft()) return result;
    // Best-effort: the room may not exist yet, but the unblock succeeded.
    await chat.markAsRead(p.roomId, p.targetUid);
    return const Right(null);
  }
}
