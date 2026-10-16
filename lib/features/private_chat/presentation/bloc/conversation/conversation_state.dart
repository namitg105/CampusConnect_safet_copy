part of 'conversation_bloc.dart';

enum UploadStatus { idle, uploading, done, failed }

final class ConversationState extends Equatable {
  final List<ChatMessage> messages;

  /// Null (or empty) when nothing is pinned.
  final PinnedMessage? pinned;
  final bool friendOnline;

  /// Photo/document upload started from a preview screen.
  final UploadStatus uploadStatus;
  final int uploadId;

  /// Last failed action; [errorId] makes repeated errors distinct.
  final String error;
  final int errorId;

  /// Phone number to open in the dialer; [dialId] makes repeats distinct.
  final String? dialNumber;
  final int dialId;

  const ConversationState({
    this.messages = const [],
    this.pinned,
    this.friendOnline = false,
    this.uploadStatus = UploadStatus.idle,
    this.uploadId = 0,
    this.error = '',
    this.errorId = 0,
    this.dialNumber,
    this.dialId = 0,
  });

  PinnedMessage? get visiblePin =>
      (pinned == null || pinned!.isEmpty) ? null : pinned;

  ConversationState copyWith({
    List<ChatMessage>? messages,
    PinnedMessage? Function()? pinned,
    bool? friendOnline,
    UploadStatus? uploadStatus,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      pinned: pinned != null ? pinned() : this.pinned,
      friendOnline: friendOnline ?? this.friendOnline,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadId: uploadStatus != null ? uploadId + 1 : uploadId,
      error: error,
      errorId: errorId,
      dialNumber: dialNumber,
      dialId: dialId,
    );
  }

  ConversationState withError(String message) => ConversationState(
        messages: messages,
        pinned: pinned,
        friendOnline: friendOnline,
        uploadStatus: uploadStatus,
        uploadId: uploadId,
        error: message,
        errorId: errorId + 1,
        dialNumber: dialNumber,
        dialId: dialId,
      );

  ConversationState withDial(String number) => ConversationState(
        messages: messages,
        pinned: pinned,
        friendOnline: friendOnline,
        uploadStatus: uploadStatus,
        uploadId: uploadId,
        error: error,
        errorId: errorId,
        dialNumber: number,
        dialId: dialId + 1,
      );

  @override
  List<Object?> get props => [
        messages,
        pinned,
        friendOnline,
        uploadStatus,
        uploadId,
        error,
        errorId,
        dialNumber,
        dialId,
      ];
}
