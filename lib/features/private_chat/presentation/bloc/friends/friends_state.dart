part of 'friends_bloc.dart';

enum FriendsOutcomeKind { success, info, error }

/// Result of the last friend action, shown as a snackbar.
final class FriendsOutcome extends Equatable {
  final FriendsOutcomeKind kind;
  final String message;
  const FriendsOutcome(this.kind, this.message);

  @override
  List<Object?> get props => [kind, message];
}

final class FriendsState extends Equatable {
  final List<AppUser> friends;
  final bool friendsLoaded;

  /// uid -> online
  final Map<String, bool> onlineStatuses;
  final Set<String> blockedUids;
  final List<FriendRequest> incomingRequests;
  final List<FriendRequest> ignoredRequests;
  final Set<String> sentRequestUids;
  final List<AppUser> directory;
  final bool directoryLoaded;
  final FriendsOutcome? outcome;

  /// Increases with every outcome so repeated messages still show.
  final int outcomeId;

  const FriendsState({
    this.friends = const [],
    this.friendsLoaded = false,
    this.onlineStatuses = const {},
    this.blockedUids = const {},
    this.incomingRequests = const [],
    this.ignoredRequests = const [],
    this.sentRequestUids = const {},
    this.directory = const [],
    this.directoryLoaded = false,
    this.outcome,
    this.outcomeId = 0,
  });

  bool isOnline(String uid) => onlineStatuses[uid] ?? false;
  bool isBlocked(String uid) => blockedUids.contains(uid);

  /// Uids of people waiting for the user to accept them.
  Set<String> get incomingRequestUids =>
      incomingRequests.map((r) => r.fromUid).toSet();

  FriendsState copyWith({
    List<AppUser>? friends,
    bool? friendsLoaded,
    Map<String, bool>? onlineStatuses,
    Set<String>? blockedUids,
    List<FriendRequest>? incomingRequests,
    List<FriendRequest>? ignoredRequests,
    Set<String>? sentRequestUids,
    List<AppUser>? directory,
    bool? directoryLoaded,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      friendsLoaded: friendsLoaded ?? this.friendsLoaded,
      onlineStatuses: onlineStatuses ?? this.onlineStatuses,
      blockedUids: blockedUids ?? this.blockedUids,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      ignoredRequests: ignoredRequests ?? this.ignoredRequests,
      sentRequestUids: sentRequestUids ?? this.sentRequestUids,
      directory: directory ?? this.directory,
      directoryLoaded: directoryLoaded ?? this.directoryLoaded,
      outcome: outcome,
      outcomeId: outcomeId,
    );
  }

  FriendsState withOutcome(FriendsOutcomeKind kind, String message) {
    return FriendsState(
      friends: friends,
      friendsLoaded: friendsLoaded,
      onlineStatuses: onlineStatuses,
      blockedUids: blockedUids,
      incomingRequests: incomingRequests,
      ignoredRequests: ignoredRequests,
      sentRequestUids: sentRequestUids,
      directory: directory,
      directoryLoaded: directoryLoaded,
      outcome: FriendsOutcome(kind, message),
      outcomeId: outcomeId + 1,
    );
  }

  @override
  List<Object?> get props => [
        friends,
        friendsLoaded,
        onlineStatuses,
        blockedUids,
        incomingRequests,
        ignoredRequests,
        sentRequestUids,
        directory,
        directoryLoaded,
        outcome,
        outcomeId,
      ];
}
