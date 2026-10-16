import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../auth/domain/entities/app_user.dart';
import '../../../domain/entities/friend_request.dart';
import '../../../domain/usecases/friends_usecases.dart';

part 'friends_event.dart';
part 'friends_state.dart';

/// App-wide friends data for the logged-in user (replaces the permanent
/// GetX `UserController` and the directory part of `ChatController`).
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final WatchFriends _watchFriends;
  final WatchOnlineStatuses _watchOnline;
  final WatchBlockedUids _watchBlocked;
  final WatchIncomingRequests _watchIncoming;
  final WatchSentRequestUids _watchSent;
  final WatchIgnoredRequests _watchIgnored;
  final WatchDirectory _watchDirectory;
  final SendFriendRequest _sendRequest;
  final AcceptFriendRequest _accept;
  final DeclineFriendRequest _decline;
  final AcceptIgnoredRequest _acceptIgnored;
  final BlockUser _block;
  final UnblockUser _unblock;

  String? _uid;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  StreamSubscription<dynamic>? _onlineSub;
  StreamSubscription<dynamic>? _directorySub;

  FriendsBloc({
    required WatchFriends watchFriends,
    required WatchOnlineStatuses watchOnlineStatuses,
    required WatchBlockedUids watchBlockedUids,
    required WatchIncomingRequests watchIncomingRequests,
    required WatchSentRequestUids watchSentRequestUids,
    required WatchIgnoredRequests watchIgnoredRequests,
    required WatchDirectory watchDirectory,
    required SendFriendRequest sendFriendRequest,
    required AcceptFriendRequest acceptFriendRequest,
    required DeclineFriendRequest declineFriendRequest,
    required AcceptIgnoredRequest acceptIgnoredRequest,
    required BlockUser blockUser,
    required UnblockUser unblockUser,
  })  : _watchFriends = watchFriends,
        _watchOnline = watchOnlineStatuses,
        _watchBlocked = watchBlockedUids,
        _watchIncoming = watchIncomingRequests,
        _watchSent = watchSentRequestUids,
        _watchIgnored = watchIgnoredRequests,
        _watchDirectory = watchDirectory,
        _sendRequest = sendFriendRequest,
        _accept = acceptFriendRequest,
        _decline = declineFriendRequest,
        _acceptIgnored = acceptIgnoredRequest,
        _block = blockUser,
        _unblock = unblockUser,
        super(const FriendsState()) {
    on<FriendsWatchStarted>(_onStarted);
    on<FriendsWatchStopped>(_onStopped);
    on<DirectoryWatchRequested>(_onDirectoryRequested);
    on<_FriendsDataChanged>((event, emit) => emit(event.apply(state)));
    on<FriendRequestSent>(_onRequestSent);
    on<FriendRequestAccepted>((event, emit) async => _reportNamed(
          emit,
          await _accept(event.request.fromUid),
          fallbackName: event.request.fromName,
          success: (name) => '$name is now your friend!',
          failurePrefix: 'Failed to accept',
        ));
    on<FriendRequestDeclined>((event, emit) async => _reportNamed(
          emit,
          await _decline(event.request.fromUid),
          fallbackName: event.request.fromName,
          success: (name) => 'Request from $name declined',
          failurePrefix: 'Failed to decline',
          kind: FriendsOutcomeKind.info,
        ));
    on<IgnoredRequestAccepted>((event, emit) async => _reportNamed(
          emit,
          await _acceptIgnored(event.request.fromUid),
          fallbackName: event.request.fromName,
          success: (name) => '$name is now your friend!',
          failurePrefix: 'Failed to accept',
        ));
    on<UserBlockRequested>((event, emit) async => _report(
          emit,
          await _block(event.targetUid),
          success: '${event.targetName} has been blocked',
          failurePrefix: 'Failed to block',
        ));
    on<UserUnblockRequested>((event, emit) async => _report(
          emit,
          await _unblock(
              UnblockParams(targetUid: event.targetUid, roomId: event.roomId)),
          success: '${event.targetName} has been unblocked',
          failurePrefix: 'Failed to unblock',
        ));
  }

  /// Forwards a listener's result into the bloc as a state change.
  /// Errors are logged and the last good data is kept (as before).
  StreamSubscription<Either<Failure, T>> _listen<T>(
    Stream<Either<Failure, T>> stream,
    FriendsState Function(FriendsState, T) apply,
    String label,
  ) {
    return stream.listen((result) => result.fold(
          (failure) => debugPrint('Friends ($label): ${failure.message}'),
          (data) => add(_FriendsDataChanged((s) => apply(s, data))),
        ));
  }

  Future<void> _onStarted(
    FriendsWatchStarted event,
    Emitter<FriendsState> emit,
  ) async {
    if (_uid == event.uid) return;
    await _cancelAll();
    emit(const FriendsState());
    _uid = event.uid;
    final uid = event.uid;

    _subscriptions.addAll([
      _watchFriends(uid).listen((result) => result.fold(
            (failure) {
              // Stop the spinner; the list stays as it was (before: same).
              debugPrint('Friends (friends): ${failure.message}');
              add(_FriendsDataChanged((s) => s.copyWith(friendsLoaded: true)));
            },
            (friends) {
              _watchOnlineFor(friends.map((f) => f.uid).toList());
              add(_FriendsDataChanged(
                  (s) => s.copyWith(friends: friends, friendsLoaded: true)));
            },
          )),
      _listen(_watchBlocked(uid),
          (s, Set<String> ids) => s.copyWith(blockedUids: ids), 'blocked'),
      _listen(
          _watchIncoming(uid),
          (s, List<FriendRequest> r) => s.copyWith(incomingRequests: r),
          'incoming requests'),
      _listen(_watchSent(uid),
          (s, Set<String> ids) => s.copyWith(sentRequestUids: ids), 'sent'),
      _listen(
          _watchIgnored(uid),
          (s, List<FriendRequest> r) => s.copyWith(ignoredRequests: r),
          'ignored requests'),
    ]);
  }

  /// Online dots follow the current friends list.
  void _watchOnlineFor(List<String> friendUids) {
    _onlineSub?.cancel();
    _onlineSub = _listen(_watchOnline(friendUids),
        (s, Map<String, bool> map) => s.copyWith(onlineStatuses: map), 'online');
  }

  Future<void> _onDirectoryRequested(
    DirectoryWatchRequested event,
    Emitter<FriendsState> emit,
  ) async {
    final uid = _uid;
    if (uid == null || _directorySub != null) return;
    _directorySub = _watchDirectory(uid).listen((result) => result.fold(
          (failure) {
            // Before: the directory was cleared so the tab still renders.
            debugPrint('Friends (directory): ${failure.message}');
            add(_FriendsDataChanged(
                (s) => s.copyWith(directory: const [], directoryLoaded: true)));
          },
          (people) => add(_FriendsDataChanged(
              (s) => s.copyWith(directory: people, directoryLoaded: true))),
        ));
  }

  Future<void> _onStopped(
    FriendsWatchStopped event,
    Emitter<FriendsState> emit,
  ) async {
    await _cancelAll();
    _uid = null;
    emit(const FriendsState());
  }

  Future<void> _onRequestSent(
    FriendRequestSent event,
    Emitter<FriendsState> emit,
  ) async {
    _report(
      emit,
      await _sendRequest(event.targetUid),
      success: 'Friend request sent to ${event.targetName}',
      failurePrefix: 'Failed to send request',
    );
  }

  void _report(
    Emitter<FriendsState> emit,
    Either<Failure, void> result, {
    required String success,
    required String failurePrefix,
  }) {
    result.fold(
      (failure) => emit(state.withOutcome(
          FriendsOutcomeKind.error, '$failurePrefix: ${failure.message}')),
      (_) => emit(state.withOutcome(FriendsOutcomeKind.success, success)),
    );
  }

  /// Like [_report], for actions that return the other person's name.
  void _reportNamed(
    Emitter<FriendsState> emit,
    Either<Failure, String> result, {
    required String fallbackName,
    required String Function(String name) success,
    required String failurePrefix,
    FriendsOutcomeKind kind = FriendsOutcomeKind.success,
  }) {
    result.fold(
      (failure) => emit(state.withOutcome(
          FriendsOutcomeKind.error, '$failurePrefix: ${failure.message}')),
      (name) => emit(
          state.withOutcome(kind, success(name.isNotEmpty ? name : fallbackName))),
    );
  }

  Future<void> _cancelAll() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    await _onlineSub?.cancel();
    _onlineSub = null;
    await _directorySub?.cancel();
    _directorySub = null;
  }

  @override
  Future<void> close() async {
    await _cancelAll();
    return super.close();
  }
}
