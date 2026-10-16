import 'package:fpdart/fpdart.dart' hide Group;

import '../../../../core/error/failures.dart';
import '../entities/group.dart';

/// Communities and who belongs to them. Implemented in the data layer.
abstract interface class GroupRepo {
  /// Every community, live.
  Stream<Either<Failure, List<Group>>> watchGroups();

  /// Ids of communities the user has joined, live.
  Stream<Either<Failure, Set<String>>> watchJoinedGroupIds(String userId);

  /// Ids of private communities the user asked to join, live.
  Stream<Either<Failure, Set<String>>> watchPendingRequestGroupIds(
      String userId);

  /// Creates the community and makes its creator the first member.
  Future<Either<Failure, void>> createGroup(Group group);

  /// Fails with "Already joined", "Group not found" or "Group is full".
  Future<Either<Failure, void>> joinGroup(String groupId, String userId);

  Future<Either<Failure, void>> leaveGroup(String groupId, String userId);

  /// Private communities: ask the admin to let the user in.
  Future<Either<Failure, void>> requestToJoin(String groupId, String userId);

  Future<Either<Failure, void>> cancelJoinRequest(
      String groupId, String userId);

  /// Uid of the community's creator/admin ('' when unknown).
  Future<Either<Failure, String>> getGroupAdminId(String groupId);
}
