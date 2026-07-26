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
