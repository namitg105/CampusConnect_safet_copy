import '../entities/message.dart';

abstract class ChatRepo {
  Stream<List<Message>> getMessages(
    String groupId,
  );

  Future<void> sendMessage(
    String groupId,
    Message message,
  );
  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
  });
}
