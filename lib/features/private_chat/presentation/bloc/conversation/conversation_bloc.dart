import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/pinned_message.dart';
import '../../../domain/repositories/private_chat_repository.dart';
import '../../../domain/usecases/private_chat_usecases.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

/// One open 1-to-1 conversation (replaces GetX `ChatController` +
/// `UserOnlineController` for the chat screen).
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final WatchRoomMessages _watchMessages;
  final WatchPinnedMessage _watchPinned;
  final WatchUserOnline _watchOnline;
  final MarkRoomAsRead _markAsRead;
  final SendPrivateMessage _send;
  final ToggleReaction _toggleReaction;
  final DeletePrivateMessage _delete;
  final PinPrivateMessage _pin;
  final UnpinPrivateMessage _unpin;
  final GetPhoneNumber _getPhoneNumber;

  String _roomId = '';
  String _currentUid = '';
  String _friendUid = '';
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  ConversationBloc({
    required WatchRoomMessages watchRoomMessages,
    required WatchPinnedMessage watchPinnedMessage,
    required WatchUserOnline watchUserOnline,
    required MarkRoomAsRead markRoomAsRead,
    required SendPrivateMessage sendPrivateMessage,
    required ToggleReaction toggleReaction,
    required DeletePrivateMessage deletePrivateMessage,
    required PinPrivateMessage pinPrivateMessage,
    required UnpinPrivateMessage unpinPrivateMessage,
    required GetPhoneNumber getPhoneNumber,
  })  : _watchMessages = watchRoomMessages,
        _watchPinned = watchPinnedMessage,
        _watchOnline = watchUserOnline,
        _markAsRead = markRoomAsRead,
        _send = sendPrivateMessage,
        _toggleReaction = toggleReaction,
        _delete = deletePrivateMessage,
        _pin = pinPrivateMessage,
        _unpin = unpinPrivateMessage,
        _getPhoneNumber = getPhoneNumber,
        super(const ConversationState()) {
    on<ConversationStarted>(_onStarted);
    on<_ConversationChanged>((event, emit) => emit(event.apply(state)));
    on<ConversationTextSent>(_onTextSent);
    on<ConversationAttachmentSent>(_onAttachmentSent);
    on<ConversationReactionToggled>((event, emit) async => _report(
        emit,
        await _toggleReaction(ReactionParams(
          roomId: _roomId,
          messageId: event.message.messageId,
          userId: _currentUid,
          emoji: event.emoji,
        ))));
    on<ConversationMessageDeleted>(_onDeleted);
    on<ConversationMessagePinned>((event, emit) async => _report(
        emit,
        await _pin(RoomMessageParams(
            roomId: _roomId, message: event.message, uid: _currentUid))));
    on<ConversationUnpinned>(
        (event, emit) async => _report(emit, await _unpin(_roomId)));
    on<ConversationCallRequested>(_onCallRequested);
  }

  Future<void> _onStarted(
    ConversationStarted event,
    Emitter<ConversationState> emit,
  ) async {
    _roomId = event.roomId;
    _currentUid = event.currentUid;
    _friendUid = event.friendUid;

    void forward<T>(Stream<Either<Failure, T>> stream,
        ConversationState Function(ConversationState, T) apply,
        {ConversationState Function(ConversationState)? onError,
        required String label}) {
      _subscriptions.add(stream.listen((result) => result.fold(
            (failure) {
              debugPrint('Conversation ($label): ${failure.message}');
              if (onError != null) add(_ConversationChanged(onError));
            },
            (data) => add(_ConversationChanged((s) => apply(s, data))),
          )));
    }

    // On errors the old controller cleared messages / the pin; same here.
    forward(_watchMessages(_roomId),
        (s, List<ChatMessage> m) => s.copyWith(messages: m),
        onError: (s) => s.copyWith(messages: const []), label: 'messages');
    forward(_watchPinned(_roomId),
        (s, PinnedMessage? p) => s.copyWith(pinned: () => p),
        onError: (s) => s.copyWith(pinned: () => null), label: 'pinned');
    forward(_watchOnline(_friendUid),
        (s, bool online) => s.copyWith(friendOnline: online),
        label: 'online');

    final read =
        await _markAsRead(RoomUserParams(roomId: _roomId, uid: _currentUid));
    read.fold((f) => debugPrint('Mark as read failed: ${f.message}'), (_) {});
  }

  OutgoingMessage _outgoing({
    required String text,
    MessageType type = MessageType.text,
    required bool friendIsBlocked,
    ChatMessage? replyTo,
    String replyToSenderLabel = '',
  }) {
    return OutgoingMessage(
      roomId: _roomId,
      senderId: _currentUid,
      receiverId: _friendUid,
      text: text,
      type: type,
      repliedMessageId: replyTo?.messageId,
      repliedMessageContent: replyTo?.message,
      repliedMessageSender: replyTo == null ? null : replyToSenderLabel,
      repliedMessageType: replyTo?.type.name,
      // A blocked friend must not get unread badges from us.
      skipUnreadIncrement: friendIsBlocked,
    );
  }

  Future<void> _onTextSent(
    ConversationTextSent event,
    Emitter<ConversationState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    _report(
      emit,
      await _send(SendPrivateMessageParams(_outgoing(
        text: text,
        friendIsBlocked: event.friendIsBlocked,
        replyTo: event.replyTo,
        replyToSenderLabel: event.replyToSenderLabel,
      ))),
    );
  }

  Future<void> _onAttachmentSent(
    ConversationAttachmentSent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(uploadStatus: UploadStatus.uploading));
    final isImage = event.type == MessageType.image;
    final result = await _send(SendPrivateMessageParams(
      _outgoing(
        text: isImage ? '📷 Photo' : event.file.name,
        type: event.type,
        friendIsBlocked: event.friendIsBlocked,
      ),
      attachment: event.file,
    ));
    result.fold(
      (failure) => emit(state
          .copyWith(uploadStatus: UploadStatus.failed)
          .withError('Upload failed: ${failure.message}')),
      (_) => emit(state.copyWith(uploadStatus: UploadStatus.done)),
    );
  }

  Future<void> _onDeleted(
    ConversationMessageDeleted event,
    Emitter<ConversationState> emit,
  ) async {
    // Fix: previously anyone could delete the other person's messages.
    if (event.message.senderId != _currentUid) {
      emit(state.withError('You can delete only your own messages.'));
      return;
    }
    _report(
      emit,
      await _delete(RoomMessageParams(
          roomId: _roomId, message: event.message, uid: _currentUid)),
    );
  }

  Future<void> _onCallRequested(
    ConversationCallRequested event,
    Emitter<ConversationState> emit,
  ) async {
    final result = await _getPhoneNumber(_friendUid);
    final number = result.getOrElse((_) => null);
    if (number == null || number.isEmpty) {
      emit(state.withError('Phone number not set'));
    } else {
      emit(state.withDial(number));
    }
  }

  void _report(Emitter<ConversationState> emit, Either<Failure, void> result) {
    result.fold((failure) => emit(state.withError(failure.message)), (_) {});
  }

  @override
  Future<void> close() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    return super.close();
  }
}
