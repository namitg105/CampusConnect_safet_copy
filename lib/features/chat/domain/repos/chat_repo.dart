import 'package:noteswap/features/chat/domain/entities/chat_message_entity.dart';
import 'package:noteswap/features/chat/domain/entities/chat_room_entity.dart';

abstract class ChatRepo {
  Stream<List<ChatRoomEntity>> getChatRooms(String collegeId);
  Future<ChatRoomEntity> createChatRoom(ChatRoomEntity room);
  Stream<List<ChatMessageEntity>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, ChatMessageEntity message);
}
