import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepo {
  final ChatRemoteDataSource remote;
  const ChatRepositoryImpl(this.remote);

  @override
  Stream<Either<Failure, List<Message>>> watchMessages(String groupId) =>
      guardStream(remote.watchMessages(groupId));

  @override
  Future<Either<Failure, void>> sendText(String groupId, String text) =>
      guardFuture(() => remote.sendText(groupId, text));

  @override
  Future<Either<Failure, void>> sendMedia(
          String groupId, MediaKind kind, ChatAttachment file) =>
      guardFuture(() => remote.sendMedia(groupId, kind, file));

  @override
  Future<Either<Failure, void>> deleteMessage(
          String groupId, String messageId) =>
      guardFuture(() => remote.deleteMessage(groupId, messageId));

  @override
  Future<Either<Failure, void>> pinMessage(String groupId, String messageId) =>
      guardFuture(() => remote.pinMessage(groupId, messageId));

  @override
  Future<Either<Failure, void>> unpinMessage(String groupId) =>
      guardFuture(() => remote.unpinMessage(groupId));
}
