import 'package:fpdart/fpdart.dart' hide Group;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../repos/group_repo.dart';

/// "This user and this community" — input of every membership use case.
class GroupMemberParams {
  final String groupId;
  final String userId;
  const GroupMemberParams({required this.groupId, required this.userId});
}

class WatchGroups implements StreamUseCase<List<Group>, NoParams> {
  final GroupRepo repo;
  const WatchGroups(this.repo);

  @override
  Stream<Either<Failure, List<Group>>> call(NoParams params) =>
      repo.watchGroups();
}

/// Params: the user id.
class WatchJoinedGroupIds implements StreamUseCase<Set<String>, String> {
  final GroupRepo repo;
  const WatchJoinedGroupIds(this.repo);

  @override
  Stream<Either<Failure, Set<String>>> call(String userId) =>
      repo.watchJoinedGroupIds(userId);
}

/// Params: the user id.
class WatchPendingJoinRequests implements StreamUseCase<Set<String>, String> {
  final GroupRepo repo;
  const WatchPendingJoinRequests(this.repo);

  @override
  Stream<Either<Failure, Set<String>>> call(String userId) =>
      repo.watchPendingRequestGroupIds(userId);
}

class CreateGroup implements UseCase<void, Group> {
  final GroupRepo repo;
  const CreateGroup(this.repo);

  @override
  Future<Either<Failure, void>> call(Group group) => repo.createGroup(group);
}

class JoinGroup implements UseCase<void, GroupMemberParams> {
  final GroupRepo repo;
  const JoinGroup(this.repo);

  @override
  Future<Either<Failure, void>> call(GroupMemberParams p) =>
      repo.joinGroup(p.groupId, p.userId);
}

class LeaveGroup implements UseCase<void, GroupMemberParams> {
  final GroupRepo repo;
  const LeaveGroup(this.repo);

  @override
  Future<Either<Failure, void>> call(GroupMemberParams p) =>
      repo.leaveGroup(p.groupId, p.userId);
}

class RequestToJoinGroup implements UseCase<void, GroupMemberParams> {
  final GroupRepo repo;
  const RequestToJoinGroup(this.repo);

  @override
  Future<Either<Failure, void>> call(GroupMemberParams p) =>
      repo.requestToJoin(p.groupId, p.userId);
}

class CancelJoinRequest implements UseCase<void, GroupMemberParams> {
  final GroupRepo repo;
  const CancelJoinRequest(this.repo);

  @override
  Future<Either<Failure, void>> call(GroupMemberParams p) =>
      repo.cancelJoinRequest(p.groupId, p.userId);
}

/// Params: the community id.
class GetGroupAdminId implements UseCase<String, String> {
  final GroupRepo repo;
  const GetGroupAdminId(this.repo);

  @override
  Future<Either<Failure, String>> call(String groupId) =>
      repo.getGroupAdminId(groupId);
}
