import '../entities/group.dart';

abstract class GroupRepo {
  Stream<List<Group>> getGroups();
  Stream<List<Group>> getJoinedGroups(String userId);
  Future<void> createGroup(Group group);

  Future<void> joinGroup(
    String groupId,
    String userId,
  );

  Future<void> leaveGroup(
    String groupId,
    String userId,
  );
}
