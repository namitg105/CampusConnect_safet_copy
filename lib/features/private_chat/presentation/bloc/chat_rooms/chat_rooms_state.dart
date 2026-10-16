part of 'chat_rooms_bloc.dart';

/// A room that is ready to be opened by the UI.
final class RoomToOpen extends Equatable {
  final String roomId;
  final String friendUid;
  final int requesterId;
  const RoomToOpen({
    required this.roomId,
    required this.friendUid,
    required this.requesterId,
  });

  @override
  List<Object?> get props => [roomId, friendUid, requesterId];
}

final class ChatRoomsState extends Equatable {
  final List<ChatRoomSummary> rooms;
  final bool loaded;

  /// Set after [ChatRoomOpenRequested]; [openId] makes each request distinct.
  final RoomToOpen? roomToOpen;
  final int openId;

  final String error;
  final int errorId;
  final int errorRequesterId;

  const ChatRoomsState({
    this.rooms = const [],
    this.loaded = false,
    this.roomToOpen,
    this.openId = 0,
    this.error = '',
    this.errorId = 0,
    this.errorRequesterId = 0,
  });

  ChatRoomsState copyWith({
    List<ChatRoomSummary>? rooms,
    bool? loaded,
    RoomToOpen? roomToOpen,
    String? error,
    int? errorRequesterId,
  }) {
    return ChatRoomsState(
      rooms: rooms ?? this.rooms,
      loaded: loaded ?? this.loaded,
      roomToOpen: roomToOpen ?? this.roomToOpen,
      openId: roomToOpen != null ? openId + 1 : openId,
      error: error ?? this.error,
      errorId: error != null ? errorId + 1 : errorId,
      errorRequesterId: errorRequesterId ?? this.errorRequesterId,
    );
  }

  @override
  List<Object?> get props => [rooms, loaded, roomToOpen, openId, error, errorId, errorRequesterId];
}
