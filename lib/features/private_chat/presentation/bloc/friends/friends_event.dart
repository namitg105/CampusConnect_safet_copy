part of 'friends_bloc.dart';

sealed class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

/// Logged in: listen to friends, blocks and friend requests.
final class FriendsWatchStarted extends FriendsEvent {
  final String uid;
  const FriendsWatchStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Logged out: stop every listener and forget the data.
final class FriendsWatchStopped extends FriendsEvent {
  const FriendsWatchStopped();
}

/// The Directory tab needs the list of everyone (started once).
final class DirectoryWatchRequested extends FriendsEvent {
  const DirectoryWatchRequested();
}

final class FriendRequestSent extends FriendsEvent {
  final String targetUid;
  final String targetName;
  const FriendRequestSent(this.targetUid, this.targetName);

  @override
  List<Object?> get props => [targetUid, targetName];
}

final class FriendRequestAccepted extends FriendsEvent {
  final FriendRequest request;
  const FriendRequestAccepted(this.request);

  @override
  List<Object?> get props => [request.fromUid];
}

final class FriendRequestDeclined extends FriendsEvent {
  final FriendRequest request;
  const FriendRequestDeclined(this.request);

  @override
  List<Object?> get props => [request.fromUid];
}

final class IgnoredRequestAccepted extends FriendsEvent {
  final FriendRequest request;
  const IgnoredRequestAccepted(this.request);

  @override
  List<Object?> get props => [request.fromUid];
}

final class UserBlockRequested extends FriendsEvent {
  final String targetUid;
  final String targetName;
  const UserBlockRequested(this.targetUid, this.targetName);

  @override
  List<Object?> get props => [targetUid, targetName];
}

final class UserUnblockRequested extends FriendsEvent {
  final String targetUid;
  final String targetName;
  final String roomId;
  const UserUnblockRequested({
    required this.targetUid,
    required this.targetName,
    required this.roomId,
  });

  @override
  List<Object?> get props => [targetUid, targetName, roomId];
}

/// Internal: one of the Firestore listeners delivered new data.
final class _FriendsDataChanged extends FriendsEvent {
  final FriendsState Function(FriendsState) apply;
  const _FriendsDataChanged(this.apply);
}
