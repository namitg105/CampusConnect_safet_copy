import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import '../../domain/usecases/chat_usecases.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// One community chat screen: live messages plus send / delete / pin.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final WatchMessages _watchMessages;
  final SendTextMessage _sendText;
  final SendMediaMessage _sendMedia;
  final DeleteMessage _deleteMessage;
  final PinMessage _pinMessage;
  final UnpinMessage _unpinMessage;

  StreamSubscription<Either<Failure, List<Message>>>? _subscription;

  ChatBloc({
    required WatchMessages watchMessages,
    required SendTextMessage sendTextMessage,
    required SendMediaMessage sendMediaMessage,
    required DeleteMessage deleteMessage,
    required PinMessage pinMessage,
    required UnpinMessage unpinMessage,
  })  : _watchMessages = watchMessages,
        _sendText = sendTextMessage,
        _sendMedia = sendMediaMessage,
        _deleteMessage = deleteMessage,
        _pinMessage = pinMessage,
        _unpinMessage = unpinMessage,
        super(const ChatState()) {
    on<ChatWatchStarted>(_onWatchStarted);
    on<_MessagesUpdated>((event, emit) => event.result.fold(
          (failure) => emit(state.copyWith(
              status: ChatStatus.error, errorMessage: failure.message)),
          (messages) => emit(
              state.copyWith(status: ChatStatus.loaded, messages: messages)),
        ));
    on<ChatTextSent>((event, emit) async => _report(
        emit, await _sendText(SendTextParams(groupId: event.groupId, text: event.text))));
    on<ChatMediaSent>((event, emit) async {
      emit(state.copyWith(uploadsInFlight: state.uploadsInFlight + 1));
      final result = await _sendMedia(SendMediaParams(
          groupId: event.groupId, kind: event.kind, file: event.file));
      emit(state.copyWith(uploadsInFlight: state.uploadsInFlight - 1));
      _report(emit, result, prefix: 'Upload failed');
    });
    on<ChatMessageDeleted>((event, emit) async => _report(
        emit,
        await _deleteMessage(MessageRefParams(
            groupId: event.groupId, messageId: event.messageId))));
    on<ChatMessagePinned>((event, emit) async => _report(
        emit,
        await _pinMessage(MessageRefParams(
            groupId: event.groupId, messageId: event.messageId)),
        prefix: 'Failed to pin message'));
    on<ChatMessageUnpinned>((event, emit) async => _report(
        emit, await _unpinMessage(event.groupId),
        prefix: 'Failed to unpin message'));
  }

  Future<void> _onWatchStarted(
    ChatWatchStarted event,
    Emitter<ChatState> emit,
  ) async {
    await _subscription?.cancel();
    emit(state.copyWith(status: ChatStatus.loading));
    _subscription = _watchMessages(event.groupId)
        .listen((result) => add(_MessagesUpdated(result)));
  }

  /// Action failures are reported without hiding the message list.
  void _report(Emitter<ChatState> emit, Either<Failure, void> result,
      {String? prefix}) {
    result.fold(
      (failure) => emit(state.withActionError(
          prefix == null ? failure.message : '$prefix: ${failure.message}')),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
