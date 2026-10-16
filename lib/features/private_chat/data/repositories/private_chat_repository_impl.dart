import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/pinned_message.dart';
import '../../domain/repositories/private_chat_repository.dart';
import '../datasources/private_chat_remote_data_source.dart';

class PrivateChatRepositoryImpl implements PrivateChatRepository {
  final PrivateChatRemoteDataSource remote;
  const PrivateChatRepositoryImpl(this.remote);

  @override
  Stream<Either<Failure, List<ChatRoomSummary>>> watchChatRooms(String uid) =>
      guardStream(remote.watchChatRooms(uid));

  @override
  Future<Either<Failure, String>> getOrCreateRoom(String uid1, String uid2) =>
      guardFuture(() => remote.getOrCreateRoom(uid1, uid2));

  @override
  Stream<Either<Failure, List<ChatMessage>>> watchMessages(String roomId) =>
      guardStream(remote.watchMessages(roomId));

  @override
  Stream<Either<Failure, PinnedMessage?>> watchPinned(String roomId) =>
      guardStream(remote.watchPinned(roomId));

  @override
  Stream<Either<Failure, bool>> watchUserOnline(String uid) =>
      guardStream(remote.watchUserOnline(uid));

  @override
  Future<Either<Failure, void>> markAsRead(String roomId, String uid) =>
      guardFuture(() => remote.markAsRead(roomId, uid));

  @override
  Future<Either<Failure, void>> sendMessage(OutgoingMessage message,
      {LocalAttachment? attachment}) {
    return guardFuture(() async {
      String? imageUrl;
      String? docUrl;
      if (attachment != null) {
        final url = await remote.uploadAttachment(
            attachment, message.type, message.senderId);
        if (message.type == MessageType.image) {
          imageUrl = url;
        } else {
          docUrl = url;
        }
      }
      await remote.sendMessage(message, imageUrl: imageUrl, docUrl: docUrl);
    });
  }

  @override
  Future<Either<Failure, void>> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  }) =>
      guardFuture(() => remote.toggleReaction(
            roomId: roomId,
            messageId: messageId,
            userId: userId,
            emoji: emoji,
          ));

  @override
  Future<Either<Failure, void>> deleteMessage(
          String roomId, ChatMessage message, String currentUid) =>
      guardFuture(() => remote.deleteMessage(roomId, message, currentUid));

  @override
  Future<Either<Failure, void>> pinMessage(
          String roomId, ChatMessage message, String pinnedByUid) =>
      guardFuture(() => remote.pinMessage(roomId, message, pinnedByUid));

  @override
  Future<Either<Failure, void>> unpinMessage(String roomId) =>
      guardFuture(() => remote.unpinMessage(roomId));

  @override
  Future<Either<Failure, RoomDetails>> getRoomDetails(
          String roomId, String currentUid) =>
      guardFuture(() => remote.getRoomDetails(roomId, currentUid));

  @override
  Future<Either<Failure, List<String>>> getSharedImages(String roomId) =>
      guardFuture(() => remote.getSharedImages(roomId));

  @override
  Future<Either<Failure, List<SharedFile>>> getSharedDocuments(
          String roomId) =>
      guardFuture(() => remote.getSharedDocuments(roomId));

  @override
  Future<Either<Failure, String?>> getPhoneNumber(String uid) =>
      guardFuture(() => remote.getPhoneNumber(uid));
}
