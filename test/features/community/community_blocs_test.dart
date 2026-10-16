import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Group;
import 'package:noteswap/core/error/failures.dart';
import 'package:noteswap/features/community/data/models/group_model.dart';
import 'package:noteswap/features/community/domain/entities/group.dart';
import 'package:noteswap/features/community/domain/repos/group_repo.dart';
import 'package:noteswap/features/community/domain/usecases/group_usecases.dart';
import 'package:noteswap/features/community/presentation/bloc/create_group/create_group_bloc.dart';
import 'package:noteswap/features/community/presentation/bloc/groups/groups_bloc.dart';
import 'package:noteswap/features/community/presentation/bloc/membership/membership_bloc.dart';

Group _group(String id, {bool isPublic = true}) => Group(
      id: id,
      name: 'Group $id',
      collegeId: 'nith.ac.in',
      description: '',
      category: 'Education',
      isPublic: isPublic,
      rules: const [],
      memberCount: 0,
      maxMembers: 50,
      remainingSeats: 50,
      createdBy: 'admin',
      imageUrl: '',
    );

class FakeGroupRepo implements GroupRepo {
  final groups = StreamController<Either<Failure, List<Group>>>();
  final joined = StreamController<Either<Failure, Set<String>>>();
  final pending = StreamController<Either<Failure, Set<String>>>();
  final calls = <String>[];
  Failure? joinFailure;
  Group? created;
  String adminId = 'admin';

  @override
  Stream<Either<Failure, List<Group>>> watchGroups() => groups.stream;

  @override
  Stream<Either<Failure, Set<String>>> watchJoinedGroupIds(String u) =>
      joined.stream;

  @override
  Stream<Either<Failure, Set<String>>> watchPendingRequestGroupIds(String u) =>
      pending.stream;

  @override
  Future<Either<Failure, void>> createGroup(Group group) async {
    created = group;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> joinGroup(String g, String u) async {
    calls.add('join:$g');
    return joinFailure != null ? Left(joinFailure!) : const Right(null);
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String g, String u) async {
    calls.add('leave:$g');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> requestToJoin(String g, String u) async {
    calls.add('request:$g');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> cancelJoinRequest(String g, String u) async {
    calls.add('cancel:$g');
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> getGroupAdminId(String g) async =>
      Right(adminId);
}

/// Hands out a new stream per watch so restarts can be observed.
class _RestartableRepo extends FakeGroupRepo {
  final List<StreamController<Either<Failure, List<Group>>>> watches;
  _RestartableRepo(this.watches);

  @override
  Stream<Either<Failure, List<Group>>> watchGroups() {
    final controller = StreamController<Either<Failure, List<Group>>>();
    watches.add(controller);
    return controller.stream;
  }
}

MembershipBloc _membership(FakeGroupRepo r) => MembershipBloc(
      watchJoinedGroupIds: WatchJoinedGroupIds(r),
      watchPendingJoinRequests: WatchPendingJoinRequests(r),
      joinGroup: JoinGroup(r),
      leaveGroup: LeaveGroup(r),
      requestToJoinGroup: RequestToJoinGroup(r),
      cancelJoinRequest: CancelJoinRequest(r),
      getGroupAdminId: GetGroupAdminId(r),
    );

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakeGroupRepo repo;
  setUp(() => repo = FakeGroupRepo());

  group('GroupsBloc', () {
    test('loading, then live lists and errors from the stream', () async {
      final bloc = GroupsBloc(watchGroups: WatchGroups(repo))
        ..add(const GroupsWatchStarted());
      await _settle();
      expect(bloc.state, const GroupLoading());

      final groups = [_group('a')];
      repo.groups.add(Right(groups));
      await _settle();
      expect(bloc.state, GroupLoaded(groups));

      repo.groups.add(const Left(ServerFailure('permission-denied')));
      await _settle();
      expect(bloc.state, const GroupError('permission-denied'));
      await bloc.close();
    });

    test('restarting (pull to refresh) cancels the previous listener',
        () async {
      final watches = <StreamController<Either<Failure, List<Group>>>>[];
      final bloc = GroupsBloc(
        watchGroups: WatchGroups(_RestartableRepo(watches)),
      )..add(const GroupsWatchStarted());
      await _settle();
      bloc.add(const GroupsWatchStarted());
      await _settle();

      expect(watches, hasLength(2));
      expect(watches.first.hasListener, isFalse);
      expect(watches.last.hasListener, isTrue);
      await bloc.close();
    });

    test('close cancels the Firestore listener', () async {
      final bloc = GroupsBloc(watchGroups: WatchGroups(repo))
        ..add(const GroupsWatchStarted());
      await _settle();
      expect(repo.groups.hasListener, isTrue);
      await bloc.close();
      expect(repo.groups.hasListener, isFalse);
    });
  });

  group('MembershipBloc', () {
    test('tracks joined and pending ids from the streams', () async {
      final bloc = _membership(repo)..add(const MembershipWatchStarted('u1'));
      await _settle();
      repo.joined.add(const Right({'a'}));
      repo.pending.add(const Right({'b'}));
      await _settle();
      expect(bloc.state.isJoined('a'), isTrue);
      expect(bloc.state.isPending('b'), isTrue);
      await bloc.close();
      expect(repo.joined.hasListener, isFalse);
    });

    test('public group: join, then success outcome', () async {
      final bloc = _membership(repo)
        ..add(MembershipJoinPressed(_group('a'), 'u1'));
      await _settle();
      expect(repo.calls, ['join:a']);
      expect(bloc.state.isJoined('a'), isTrue);
      expect(bloc.state.outcome!.message, 'Joined Group a');
      expect(bloc.state.outcome!.isError, isFalse);
      await bloc.close();
    });

    test('private group: sends a request instead of joining', () async {
      final bloc = _membership(repo)
        ..add(MembershipJoinPressed(_group('p', isPublic: false), 'u1'));
      await _settle();
      expect(repo.calls, ['request:p']);
      expect(bloc.state.isPending('p'), isTrue);
      await bloc.close();
    });

    test('a full group reports the error; repeated errors still notify',
        () async {
      repo.joinFailure = const ServerFailure('Group is full');
      final bloc = _membership(repo)
        ..add(MembershipJoinPressed(_group('a'), 'u1'));
      await _settle();
      expect(bloc.state.outcome!.isError, isTrue);
      expect(bloc.state.outcome!.message, 'Group is full');
      final firstId = bloc.state.outcomeId;

      bloc.add(MembershipJoinPressed(_group('a'), 'u1'));
      await _settle();
      expect(bloc.state.outcomeId, firstId + 1);
      await bloc.close();
    });

    test('admin is blocked from leaving when blockIfAdmin is set', () async {
      final bloc = _membership(repo)
        ..add(const MembershipLeavePressed(
            groupId: 'a', groupName: 'A', userId: 'admin', blockIfAdmin: true));
      await _settle();
      expect(repo.calls, isEmpty);
      expect(bloc.state.outcome!.isError, isTrue);
      await bloc.close();
    });

    test('a normal member leaves through the repository', () async {
      final bloc = _membership(repo)
        ..add(const MembershipLeavePressed(
            groupId: 'a', groupName: 'A', userId: 'u1', blockIfAdmin: true));
      await _settle();
      expect(repo.calls, ['leave:a']);
      expect(bloc.state.outcome!.message, 'Left A');
      await bloc.close();
    });

    test('cancel request removes it from pending', () async {
      final bloc = _membership(repo)
        ..add(MembershipJoinPressed(_group('p', isPublic: false), 'u1'));
      await _settle();
      bloc.add(MembershipCancelRequestPressed(_group('p', isPublic: false), 'u1'));
      await _settle();
      expect(repo.calls, ['request:p', 'cancel:p']);
      expect(bloc.state.isPending('p'), isFalse);
      await bloc.close();
    });

    test('signed-out user cannot act', () async {
      final bloc = _membership(repo)..add(MembershipJoinPressed(_group('a'), ''));
      await _settle();
      expect(repo.calls, isEmpty);
      await bloc.close();
    });
  });

  group('CreateGroupBloc', () {
    test('creates a trimmed community owned by the user', () async {
      final bloc = CreateGroupBloc(createGroup: CreateGroup(repo))
        ..add(const CreateGroupSubmitted(
          name: ' Chess ',
          description: ' Play ',
          collegeId: 'nith.ac.in',
          category: 'Gaming',
          isPublic: false,
          rules: ['Be kind'],
          creatorId: 'u1',
        ));
      await expectLater(
        bloc.stream.map((s) => s.status),
        emitsInOrder(
            [CreateGroupStatus.submitting, CreateGroupStatus.success]),
      );
      expect(repo.created!.name, 'Chess');
      expect(repo.created!.createdBy, 'u1');
      expect(repo.created!.isPublic, isFalse);
      await bloc.close();
    });

    test('signed-out user gets an error without saving', () async {
      final bloc = CreateGroupBloc(createGroup: CreateGroup(repo))
        ..add(const CreateGroupSubmitted(
          name: 'X',
          description: '',
          collegeId: '',
          category: 'Gaming',
          isPublic: true,
          rules: [],
          creatorId: '',
        ));
      await _settle();
      expect(bloc.state.status, CreateGroupStatus.failure);
      expect(repo.created, isNull);
      await bloc.close();
    });
  });

  group('GroupModel', () {
    test('round-trips and applies defaults', () {
      final map = GroupModel.toMap(_group('a').copyWith(
        createdAt: DateTime(2026, 1, 2),
      ));
      final back = GroupModel.fromMap('a', map);
      expect(back.name, 'Group a');
      expect(back.createdAt, DateTime(2026, 1, 2));

      final empty = GroupModel.fromMap('z', {});
      expect(empty.category, 'Education');
      expect(empty.maxMembers, 50);
      expect(empty.isPublic, isTrue);
    });
  });
}
