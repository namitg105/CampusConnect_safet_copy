import '../entities/group.dart';

abstract class GroupRepo {
  Stream<List<Group>> getGroups(
    String collegeId,
  );

  Future<void> createGroup(
    Group group,
  );

  Future<void> joinGroup(
    String groupId,
    String userId,
  );
}
