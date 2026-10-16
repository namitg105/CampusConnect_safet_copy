part of 'membership_bloc.dart';

sealed class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to the user's joined communities and pending requests.
final class MembershipWatchStarted extends MembershipEvent {
  final String userId;
  const MembershipWatchStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// "Join" tapped: joins a public community or requests a private one.
final class MembershipJoinPressed extends MembershipEvent {
  final Group group;
  final String userId;
  const MembershipJoinPressed(this.group, this.userId);

  @override
  List<Object?> get props => [group.id, userId];
}

final class MembershipLeavePressed extends MembershipEvent {
  final String groupId;
  final String groupName;
  final String userId;

  /// When true, the community's admin is told to leave via the profile
  /// page instead (so ownership can be transferred).
  final bool blockIfAdmin;

  const MembershipLeavePressed({
    required this.groupId,
    required this.groupName,
    required this.userId,
    this.blockIfAdmin = false,
  });

  @override
  List<Object?> get props => [groupId, groupName, userId, blockIfAdmin];
}

final class MembershipCancelRequestPressed extends MembershipEvent {
  final Group group;
  final String userId;
  const MembershipCancelRequestPressed(this.group, this.userId);

  @override
  List<Object?> get props => [group.id, userId];
}

final class _JoinedIdsUpdated extends MembershipEvent {
  final Either<Failure, Set<String>> result;
  const _JoinedIdsUpdated(this.result);

  @override
  List<Object?> get props => [result];
}

final class _PendingIdsUpdated extends MembershipEvent {
  final Either<Failure, Set<String>> result;
  const _PendingIdsUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
