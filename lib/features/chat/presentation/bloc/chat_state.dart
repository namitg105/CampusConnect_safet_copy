part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, error }

final class ChatState extends Equatable {
  final ChatStatus status;
  final List<Message> messages;

  /// Why the message stream failed (status == error).
  final String errorMessage;

  /// Photos/videos/documents currently being compressed and uploaded.
  final int uploadsInFlight;

  bool get isUploading => uploadsInFlight > 0;

  /// Last failed action (send, delete, pin). [actionErrorId] increases each
  /// time so the snackbar shows even for a repeated message.
  final String actionError;
  final int actionErrorId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage = '',
    this.uploadsInFlight = 0,
    this.actionError = '',
    this.actionErrorId = 0,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? errorMessage,
    int? uploadsInFlight,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadsInFlight: uploadsInFlight ?? this.uploadsInFlight,
      actionError: actionError,
      actionErrorId: actionErrorId,
    );
  }

  ChatState withActionError(String message) {
    return ChatState(
      status: status,
      messages: messages,
      errorMessage: errorMessage,
      uploadsInFlight: uploadsInFlight,
      actionError: message,
      actionErrorId: actionErrorId + 1,
    );
  }

  @override
  List<Object?> get props =>
      [status, messages, errorMessage, uploadsInFlight, actionError, actionErrorId];
}
