import '../entities/message.dart';

abstract class ChatRepo {
  Stream<List<Message>> getMessages(
    String groupId,
  );

  Future<void> sendMessage(
    String groupId,
    Message message,
  );
}
