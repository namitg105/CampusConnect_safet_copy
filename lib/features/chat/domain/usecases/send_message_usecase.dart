import 'package:noteswap/features/chat/domain/entities/chat_message_entity.dart';
import 'package:noteswap/features/chat/domain/repos/chat_repo.dart';

class SendMessageUseCase {
  final ChatRepo repository;

  SendMessageUseCase({required this.repository});

  Future<void> call(String roomId, ChatMessageEntity message) {
    return repository.sendMessage(roomId, message);
  }
}
