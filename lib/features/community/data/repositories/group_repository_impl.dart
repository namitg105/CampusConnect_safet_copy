import 'package:fpdart/fpdart.dart' hide Group;

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/group.dart';
import '../../domain/repos/group_repo.dart';
import '../datasources/group_remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepo {
  final GroupRemoteDataSource remote;
  const GroupRepositoryImpl(this.remote);

  @override
  Stream<Either<Failure, List<Group>>> watchGroups() =>
      guardStream(remote.watchGroups());

  @override
  Stream<Either<Failure, Set<String>>> watchJoinedGroupIds(String userId) =>
      guardStream(remote.watchJoinedGroupIds(userId));

  @override
  Stream<Either<Failure, Set<String>>> watchPendingRequestGroupIds(
          String userId) =>
      guardStream(remote.watchPendingRequestGroupIds(userId));

  @override
  Future<Either<Failure, void>> createGroup(Group group) =>
      guardFuture(() => remote.createGroup(group));

  @override
  Future<Either<Failure, void>> joinGroup(String groupId, String userId) =>
      guardFuture(() => remote.joinGroup(groupId, userId));

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId, String userId) =>
      guardFuture(() => remote.leaveGroup(groupId, userId));

  @override
  Future<Either<Failure, void>> requestToJoin(String groupId, String userId) =>
      guardFuture(() => remote.requestToJoin(groupId, userId));

  @override
  Future<Either<Failure, void>> cancelJoinRequest(
          String groupId, String userId) =>
      guardFuture(() => remote.cancelJoinRequest(groupId, userId));

  @override
  Future<Either<Failure, String>> getGroupAdminId(String groupId) =>
      guardFuture(() => remote.getGroupAdminId(groupId));
}
