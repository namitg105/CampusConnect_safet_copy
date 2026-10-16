part of 'chat_rooms_bloc.dart';

sealed class ChatRoomsEvent extends Equatable {
  const ChatRoomsEvent();

  @override
  List<Object?> get props => [];
}

final class ChatRoomsWatchStarted extends ChatRoomsEvent {
  final String uid;
  const ChatRoomsWatchStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// A friend was tapped in Recent Chats.
final class ChatRoomOpenRequested extends ChatRoomsEvent {
  final String currentUid;
  final String friendUid;

  /// Identifies the widget that asked, so only it reacts to the result.
  final int requesterId;

  const ChatRoomOpenRequested({
    required this.currentUid,
    required this.friendUid,
    required this.requesterId,
  });

  @override
  List<Object?> get props => [currentUid, friendUid, requesterId];
}

final class _RoomsChanged extends ChatRoomsEvent {
  final List<ChatRoomSummary> rooms;
  const _RoomsChanged(this.rooms);

  @override
  List<Object?> get props => [rooms];
}
