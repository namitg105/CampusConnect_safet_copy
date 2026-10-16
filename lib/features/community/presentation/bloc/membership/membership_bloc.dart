import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide Group;

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/usecases/group_usecases.dart';

part 'membership_event.dart';
part 'membership_state.dart';

/// The current user's relationship with communities: which ones they have
/// joined or asked to join, plus join / leave / request / cancel actions.
class MembershipBloc extends Bloc<MembershipEvent, MembershipState> {
  final WatchJoinedGroupIds _watchJoined;
  final WatchPendingJoinRequests _watchPending;
  final JoinGroup _join;
  final LeaveGroup _leave;
  final RequestToJoinGroup _request;
  final CancelJoinRequest _cancelRequest;
  final GetGroupAdminId _getAdminId;

  StreamSubscription<Either<Failure, Set<String>>>? _joinedSub;
  StreamSubscription<Either<Failure, Set<String>>>? _pendingSub;

  MembershipBloc({
    required WatchJoinedGroupIds watchJoinedGroupIds,
    required WatchPendingJoinRequests watchPendingJoinRequests,
    required JoinGroup joinGroup,
    required LeaveGroup leaveGroup,
    required RequestToJoinGroup requestToJoinGroup,
    required CancelJoinRequest cancelJoinRequest,
    required GetGroupAdminId getGroupAdminId,
  })  : _watchJoined = watchJoinedGroupIds,
        _watchPending = watchPendingJoinRequests,
        _join = joinGroup,
        _leave = leaveGroup,
        _request = requestToJoinGroup,
        _cancelRequest = cancelJoinRequest,
        _getAdminId = getGroupAdminId,
        super(const MembershipState()) {
    on<MembershipWatchStarted>(_onWatchStarted);
    on<_JoinedIdsUpdated>((event, emit) => event.result.fold(
          (_) {}, // keep the last known ids
          (ids) => emit(state.copyWith(joinedGroupIds: ids)),
        ));
    on<_PendingIdsUpdated>((event, emit) => event.result.fold(
          (_) {},
          (ids) => emit(state.copyWith(pendingGroupIds: ids)),
        ));
    on<MembershipJoinPressed>(_onJoinPressed);
    on<MembershipLeavePressed>(_onLeavePressed);
    on<MembershipCancelRequestPressed>(_onCancelPressed);
  }

  Future<void> _onWatchStarted(
    MembershipWatchStarted event,
    Emitter<MembershipState> emit,
  ) async {
    await _joinedSub?.cancel();
    await _pendingSub?.cancel();
    if (event.userId.isEmpty) return;
    _joinedSub = _watchJoined(event.userId)
        .listen((result) => add(_JoinedIdsUpdated(result)));
    _pendingSub = _watchPending(event.userId)
        .listen((result) => add(_PendingIdsUpdated(result)));
  }

  /// Public community: join now. Private: send a request to the admin.
  Future<void> _onJoinPressed(
    MembershipJoinPressed event,
    Emitter<MembershipState> emit,
  ) async {
    if (event.userId.isEmpty) return;
    final group = event.group;
    final params = GroupMemberParams(groupId: group.id, userId: event.userId);

    if (group.isPublic) {
      final result = await _join(params);
      _emitOutcome(emit, result, MembershipAction.joined, group.id,
          success: 'Joined ${group.name}',
          onSuccess: (s) =>
              s.copyWith(joinedGroupIds: {...s.joinedGroupIds, group.id}));
    } else {
      final result = await _request(params);
      _emitOutcome(emit, result, MembershipAction.requested, group.id,
          success: 'Request sent to join ${group.name}',
          onSuccess: (s) =>
              s.copyWith(pendingGroupIds: {...s.pendingGroupIds, group.id}));
    }
  }

  Future<void> _onLeavePressed(
    MembershipLeavePressed event,
    Emitter<MembershipState> emit,
  ) async {
    if (event.userId.isEmpty) return;

    if (event.blockIfAdmin) {
      final adminId = await _getAdminId(event.groupId);
      final isAdmin = adminId.getOrElse((_) => '') == event.userId;
      if (isAdmin) {
        emit(state.withOutcome(MembershipOutcome(
          action: MembershipAction.left,
          groupId: event.groupId,
          message: 'As community admin, please leave via the Community '
              'Profile page to transfer ownership.',
          isError: true,
        )));
        return;
      }
    }

    final result = await _leave(
        GroupMemberParams(groupId: event.groupId, userId: event.userId));
    _emitOutcome(emit, result, MembershipAction.left, event.groupId,
        success: 'Left ${event.groupName}',
        onSuccess: (s) => s.copyWith(
            joinedGroupIds: {...s.joinedGroupIds}..remove(event.groupId)));
  }

  Future<void> _onCancelPressed(
    MembershipCancelRequestPressed event,
    Emitter<MembershipState> emit,
  ) async {
    if (event.userId.isEmpty) return;
    final result = await _cancelRequest(
        GroupMemberParams(groupId: event.group.id, userId: event.userId));
    _emitOutcome(emit, result, MembershipAction.cancelled, event.group.id,
        success: 'Cancelled request for ${event.group.name}',
        onSuccess: (s) => s.copyWith(
            pendingGroupIds: {...s.pendingGroupIds}..remove(event.group.id)));
  }

  /// One place that turns a use-case result into the snackbar outcome.
  void _emitOutcome(
    Emitter<MembershipState> emit,
    Either<Failure, void> result,
    MembershipAction action,
    String groupId, {
    required String success,
    required MembershipState Function(MembershipState) onSuccess,
  }) {
    result.fold(
      (failure) => emit(state.withOutcome(MembershipOutcome(
        action: action,
        groupId: groupId,
        message: failure.message,
        isError: true,
      ))),
      (_) => emit(onSuccess(state).withOutcome(MembershipOutcome(
        action: action,
        groupId: groupId,
        message: success,
      ))),
    );
  }

  @override
  Future<void> close() async {
    await _joinedSub?.cancel();
    await _pendingSub?.cancel();
    return super.close();
  }
}
