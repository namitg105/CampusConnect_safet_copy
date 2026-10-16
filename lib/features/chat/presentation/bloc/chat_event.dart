part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatWatchStarted extends ChatEvent {
  final String groupId;
  const ChatWatchStarted(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

final class ChatTextSent extends ChatEvent {
  final String groupId;
  final String text;
  const ChatTextSent({required this.groupId, required this.text});

  @override
  List<Object?> get props => [groupId, text];
}

/// The user picked a photo, video or document to send.
final class ChatMediaSent extends ChatEvent {
  final String groupId;
  final MediaKind kind;
  final ChatAttachment file;
  const ChatMediaSent({
    required this.groupId,
    required this.kind,
    required this.file,
  });

  @override
  List<Object?> get props => [groupId, kind, file.path];
}

final class ChatMessageDeleted extends ChatEvent {
  final String groupId;
  final String messageId;
  const ChatMessageDeleted({required this.groupId, required this.messageId});

  @override
  List<Object?> get props => [groupId, messageId];
}

final class ChatMessagePinned extends ChatEvent {
  final String groupId;
  final String messageId;
  const ChatMessagePinned({required this.groupId, required this.messageId});

  @override
  List<Object?> get props => [groupId, messageId];
}

final class ChatMessageUnpinned extends ChatEvent {
  final String groupId;
  const ChatMessageUnpinned(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

final class _MessagesUpdated extends ChatEvent {
  final Either<Failure, List<Message>> result;
  const _MessagesUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
