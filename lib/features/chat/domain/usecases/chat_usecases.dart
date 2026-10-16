import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/message.dart';
import '../repos/chat_repo.dart';

/// Params: the community id.
class WatchMessages implements StreamUseCase<List<Message>, String> {
  final ChatRepo repo;
  const WatchMessages(this.repo);

  @override
  Stream<Either<Failure, List<Message>>> call(String groupId) =>
      repo.watchMessages(groupId);
}

class SendTextParams {
  final String groupId;
  final String text;
  const SendTextParams({required this.groupId, required this.text});
}

class SendTextMessage implements UseCase<void, SendTextParams> {
  final ChatRepo repo;
  const SendTextMessage(this.repo);

  @override
  Future<Either<Failure, void>> call(SendTextParams p) =>
      repo.sendText(p.groupId, p.text);
}

class SendMediaParams {
  final String groupId;
  final MediaKind kind;
  final ChatAttachment file;
  const SendMediaParams({
    required this.groupId,
    required this.kind,
    required this.file,
  });
}

class SendMediaMessage implements UseCase<void, SendMediaParams> {
  final ChatRepo repo;
  const SendMediaMessage(this.repo);

  @override
  Future<Either<Failure, void>> call(SendMediaParams p) =>
      repo.sendMedia(p.groupId, p.kind, p.file);
}

class MessageRefParams {
  final String groupId;
  final String messageId;
  const MessageRefParams({required this.groupId, required this.messageId});
}

class DeleteMessage implements UseCase<void, MessageRefParams> {
  final ChatRepo repo;
  const DeleteMessage(this.repo);

  @override
  Future<Either<Failure, void>> call(MessageRefParams p) =>
      repo.deleteMessage(p.groupId, p.messageId);
}

class PinMessage implements UseCase<void, MessageRefParams> {
  final ChatRepo repo;
  const PinMessage(this.repo);

  @override
  Future<Either<Failure, void>> call(MessageRefParams p) =>
      repo.pinMessage(p.groupId, p.messageId);
}

/// Params: the community id.
class UnpinMessage implements UseCase<void, String> {
  final ChatRepo repo;
  const UnpinMessage(this.repo);

  @override
  Future<Either<Failure, void>> call(String groupId) =>
      repo.unpinMessage(groupId);
}
