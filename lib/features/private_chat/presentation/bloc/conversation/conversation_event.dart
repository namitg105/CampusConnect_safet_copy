part of 'conversation_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Chat screen opened: listen to messages, pin and the friend's status,
/// and mark the room as read.
final class ConversationStarted extends ConversationEvent {
  final String roomId;
  final String currentUid;
  final String friendUid;
  const ConversationStarted({
    required this.roomId,
    required this.currentUid,
    required this.friendUid,
  });

  @override
  List<Object?> get props => [roomId, currentUid, friendUid];
}

final class ConversationTextSent extends ConversationEvent {
  final String text;
  final ChatMessage? replyTo;

  /// Shown on the reply preview ("You" or the friend's name).
  final String replyToSenderLabel;
  final bool friendIsBlocked;

  const ConversationTextSent({
    required this.text,
    this.replyTo,
    this.replyToSenderLabel = '',
    this.friendIsBlocked = false,
  });

  @override
  List<Object?> get props => [text, replyTo?.messageId, friendIsBlocked];
}

/// Photo or document confirmed on a preview screen.
final class ConversationAttachmentSent extends ConversationEvent {
  final LocalAttachment file;
  final MessageType type; // image or doc
  final bool friendIsBlocked;

  const ConversationAttachmentSent({
    required this.file,
    required this.type,
    this.friendIsBlocked = false,
  });

  @override
  List<Object?> get props => [file.path, type, friendIsBlocked];
}

final class ConversationReactionToggled extends ConversationEvent {
  final ChatMessage message;
  final String emoji;
  const ConversationReactionToggled(this.message, this.emoji);

  @override
  List<Object?> get props => [message.messageId, emoji];
}

final class ConversationMessageDeleted extends ConversationEvent {
  final ChatMessage message;
  const ConversationMessageDeleted(this.message);

  @override
  List<Object?> get props => [message.messageId];
}

final class ConversationMessagePinned extends ConversationEvent {
  final ChatMessage message;
  const ConversationMessagePinned(this.message);

  @override
  List<Object?> get props => [message.messageId];
}

final class ConversationUnpinned extends ConversationEvent {
  const ConversationUnpinned();
}

/// Call button: look up the friend's phone number.
final class ConversationCallRequested extends ConversationEvent {
  const ConversationCallRequested();
}

final class _ConversationChanged extends ConversationEvent {
  final ConversationState Function(ConversationState) apply;
  const _ConversationChanged(this.apply);
}
