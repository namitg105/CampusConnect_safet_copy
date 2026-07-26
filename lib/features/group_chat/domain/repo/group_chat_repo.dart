import '../entities/group_chat.dart';

abstract class GroupChatRepo {
  /// Streams messages in real-time from the 'group_chats' collection for a specific group.
  Stream<List<GroupChat>> streamMessages(String groupId);

  /// Sends a new message to the 'group_chats' collection.
  Future<void> sendMessage(GroupChat message);

  /// Deletes a specific message from the 'group_chats' collection.
  Future<void> deleteMessage(String messageId);
}
