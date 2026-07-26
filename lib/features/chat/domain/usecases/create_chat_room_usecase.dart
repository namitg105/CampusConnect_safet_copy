import 'package:noteswap/features/chat/domain/entities/chat_room_entity.dart';
import 'package:noteswap/features/chat/domain/repos/chat_repo.dart';

class CreateChatRoomUseCase {
  final ChatRepo repository;

  CreateChatRoomUseCase({required this.repository});

  Future<ChatRoomEntity> call(ChatRoomEntity room) {
    return repository.createChatRoom(room);
  }
}
