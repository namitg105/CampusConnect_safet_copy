import 'package:noteswap/features/chat/domain/entities/chat_room_entity.dart';
import 'package:noteswap/features/chat/domain/repos/chat_repo.dart';

class GetChatRoomsUseCase {
  final ChatRepo repository;

  GetChatRoomsUseCase({required this.repository});

  Stream<List<ChatRoomEntity>> call(String collegeId) {
    return repository.getChatRooms(collegeId);
  }
}
