part of 'membership_bloc.dart';

enum MembershipAction { joined, requested, left, cancelled }

/// Result of the last finished action, shown as a snackbar.
final class MembershipOutcome extends Equatable {
  final MembershipAction action;
  final String groupId;
  final String message;
  final bool isError;

  const MembershipOutcome({
    required this.action,
    required this.groupId,
    required this.message,
    this.isError = false,
  });

  @override
  List<Object?> get props => [action, groupId, message, isError];
}

final class MembershipState extends Equatable {
  final Set<String> joinedGroupIds;
  final Set<String> pendingGroupIds;
  final MembershipOutcome? outcome;

  /// Increases with every outcome so listeners fire even when the same
  /// message repeats.
  final int outcomeId;

  const MembershipState({
    this.joinedGroupIds = const {},
    this.pendingGroupIds = const {},
    this.outcome,
    this.outcomeId = 0,
  });

  bool isJoined(String groupId) => joinedGroupIds.contains(groupId);
  bool isPending(String groupId) => pendingGroupIds.contains(groupId);

  MembershipState copyWith({
    Set<String>? joinedGroupIds,
    Set<String>? pendingGroupIds,
  }) {
    return MembershipState(
      joinedGroupIds: joinedGroupIds ?? this.joinedGroupIds,
      pendingGroupIds: pendingGroupIds ?? this.pendingGroupIds,
      outcome: outcome,
      outcomeId: outcomeId,
    );
  }

  MembershipState withOutcome(MembershipOutcome outcome) {
    return MembershipState(
      joinedGroupIds: joinedGroupIds,
      pendingGroupIds: pendingGroupIds,
      outcome: outcome,
      outcomeId: outcomeId + 1,
    );
  }

  @override
  List<Object?> get props =>
      [joinedGroupIds, pendingGroupIds, outcome, outcomeId];
}
