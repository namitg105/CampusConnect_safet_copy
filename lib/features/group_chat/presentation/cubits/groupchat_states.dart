import '../../domain/entities/group_chat.dart';

abstract class GroupChatState {}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  final List<GroupChat> messages;

  GroupChatLoaded(this.messages);
}

class GroupChatError extends GroupChatState {
  final String message;

  GroupChatError(this.message);
}

/// Kept to match your 'GroupFull' style pattern.
/// Useful if you impose characters/size limits or if the chat room is locked.
class GroupChatFull extends GroupChatState {
  final String message;

  GroupChatFull(this.message);
}
