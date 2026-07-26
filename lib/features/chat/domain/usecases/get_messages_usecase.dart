import 'package:noteswap/features/chat/domain/entities/chat_message_entity.dart';
import 'package:noteswap/features/chat/domain/repos/chat_repo.dart';

class GetMessagesUseCase {
  final ChatRepo repository;

  GetMessagesUseCase({required this.repository});

  Stream<List<ChatMessageEntity>> call(String roomId) {
    return repository.getMessages(roomId);
  }
}
