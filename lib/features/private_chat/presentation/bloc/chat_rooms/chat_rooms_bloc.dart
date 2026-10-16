import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_room.dart';
import '../../../domain/usecases/private_chat_usecases.dart';

part 'chat_rooms_event.dart';
part 'chat_rooms_state.dart';

/// The user's 1-to-1 rooms (Recent Chats), plus opening a room.
class ChatRoomsBloc extends Bloc<ChatRoomsEvent, ChatRoomsState> {
  final WatchChatRooms _watchRooms;
  final GetOrCreateChatRoom _getOrCreateRoom;
  StreamSubscription<dynamic>? _subscription;

  ChatRoomsBloc({
    required WatchChatRooms watchChatRooms,
    required GetOrCreateChatRoom getOrCreateChatRoom,
  })  : _watchRooms = watchChatRooms,
        _getOrCreateRoom = getOrCreateChatRoom,
        super(const ChatRoomsState()) {
    on<ChatRoomsWatchStarted>(_onStarted);
    on<_RoomsChanged>((event, emit) =>
        emit(state.copyWith(rooms: event.rooms, loaded: true)));
    on<ChatRoomOpenRequested>(_onOpenRequested);
  }

  Future<void> _onStarted(
    ChatRoomsWatchStarted event,
    Emitter<ChatRoomsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _watchRooms(event.uid).listen((result) => result.fold(
          (failure) {
            // Before: the list was cleared on error.
            debugPrint('Chat rooms: ${failure.message}');
            add(const _RoomsChanged([]));
          },
          (rooms) => add(_RoomsChanged(rooms)),
        ));
  }

  /// Makes sure the room exists, then asks the UI to open it.
  Future<void> _onOpenRequested(
    ChatRoomOpenRequested event,
    Emitter<ChatRoomsState> emit,
  ) async {
    final result =
        await _getOrCreateRoom(RoomMembersParams(event.currentUid, event.friendUid));
    result.fold(
      (failure) => emit(state.copyWith(
          error: failure.message, errorRequesterId: event.requesterId)),
      (roomId) => emit(state.copyWith(
        roomToOpen: RoomToOpen(
          roomId: roomId,
          friendUid: event.friendUid,
          requesterId: event.requesterId,
        ),
      )),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
