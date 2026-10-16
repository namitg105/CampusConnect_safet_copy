import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';
import '../entities/pinned_message.dart';
import '../repositories/private_chat_repository.dart';

/// Params: the current user's uid.
class WatchChatRooms implements StreamUseCase<List<ChatRoomSummary>, String> {
  final PrivateChatRepository repo;
  const WatchChatRooms(this.repo);
  @override
  Stream<Either<Failure, List<ChatRoomSummary>>> call(String uid) =>
      repo.watchChatRooms(uid);
}

class RoomMembersParams {
  final String uid1;
  final String uid2;
  const RoomMembersParams(this.uid1, this.uid2);
}

/// Returns the room id.
class GetOrCreateChatRoom implements UseCase<String, RoomMembersParams> {
  final PrivateChatRepository repo;
  const GetOrCreateChatRoom(this.repo);
  @override
  Future<Either<Failure, String>> call(RoomMembersParams p) =>
      repo.getOrCreateRoom(p.uid1, p.uid2);
}

/// Params: the room id.
class WatchRoomMessages implements StreamUseCase<List<ChatMessage>, String> {
  final PrivateChatRepository repo;
  const WatchRoomMessages(this.repo);
  @override
  Stream<Either<Failure, List<ChatMessage>>> call(String roomId) =>
      repo.watchMessages(roomId);
}

/// Params: the room id.
class WatchPinnedMessage implements StreamUseCase<PinnedMessage?, String> {
  final PrivateChatRepository repo;
  const WatchPinnedMessage(this.repo);
  @override
  Stream<Either<Failure, PinnedMessage?>> call(String roomId) =>
      repo.watchPinned(roomId);
}

/// Params: the other user's uid.
class WatchUserOnline implements StreamUseCase<bool, String> {
  final PrivateChatRepository repo;
  const WatchUserOnline(this.repo);
  @override
  Stream<Either<Failure, bool>> call(String uid) => repo.watchUserOnline(uid);
}

class RoomUserParams {
  final String roomId;
  final String uid;
  const RoomUserParams({required this.roomId, required this.uid});
}

class MarkRoomAsRead implements UseCase<void, RoomUserParams> {
  final PrivateChatRepository repo;
  const MarkRoomAsRead(this.repo);
  @override
  Future<Either<Failure, void>> call(RoomUserParams p) =>
      repo.markAsRead(p.roomId, p.uid);
}

class SendPrivateMessageParams {
  final OutgoingMessage message;
  final LocalAttachment? attachment;
  const SendPrivateMessageParams(this.message, {this.attachment});
}

class SendPrivateMessage implements UseCase<void, SendPrivateMessageParams> {
  final PrivateChatRepository repo;
  const SendPrivateMessage(this.repo);
  @override
  Future<Either<Failure, void>> call(SendPrivateMessageParams p) =>
      repo.sendMessage(p.message, attachment: p.attachment);
}

class ReactionParams {
  final String roomId;
  final String messageId;
  final String userId;
  final String emoji;
  const ReactionParams({
    required this.roomId,
    required this.messageId,
    required this.userId,
    required this.emoji,
  });
}

class ToggleReaction implements UseCase<void, ReactionParams> {
  final PrivateChatRepository repo;
  const ToggleReaction(this.repo);
  @override
  Future<Either<Failure, void>> call(ReactionParams p) => repo.toggleReaction(
        roomId: p.roomId,
        messageId: p.messageId,
        userId: p.userId,
        emoji: p.emoji,
      );
}

class RoomMessageParams {
  final String roomId;
  final ChatMessage message;
  final String uid;
  const RoomMessageParams({
    required this.roomId,
    required this.message,
    required this.uid,
  });
}

class DeletePrivateMessage implements UseCase<void, RoomMessageParams> {
  final PrivateChatRepository repo;
  const DeletePrivateMessage(this.repo);
  @override
  Future<Either<Failure, void>> call(RoomMessageParams p) =>
      repo.deleteMessage(p.roomId, p.message, p.uid);
}

class PinPrivateMessage implements UseCase<void, RoomMessageParams> {
  final PrivateChatRepository repo;
  const PinPrivateMessage(this.repo);
  @override
  Future<Either<Failure, void>> call(RoomMessageParams p) =>
      repo.pinMessage(p.roomId, p.message, p.uid);
}

/// Params: the room id.
class UnpinPrivateMessage implements UseCase<void, String> {
  final PrivateChatRepository repo;
  const UnpinPrivateMessage(this.repo);
  @override
  Future<Either<Failure, void>> call(String roomId) =>
      repo.unpinMessage(roomId);
}

class GetRoomDetails implements UseCase<RoomDetails, RoomUserParams> {
  final PrivateChatRepository repo;
  const GetRoomDetails(this.repo);
  @override
  Future<Either<Failure, RoomDetails>> call(RoomUserParams p) =>
      repo.getRoomDetails(p.roomId, p.uid);
}

/// Params: the room id.
class GetSharedImages implements UseCase<List<String>, String> {
  final PrivateChatRepository repo;
  const GetSharedImages(this.repo);
  @override
  Future<Either<Failure, List<String>>> call(String roomId) =>
      repo.getSharedImages(roomId);
}

/// Params: the room id.
class GetSharedDocuments implements UseCase<List<SharedFile>, String> {
  final PrivateChatRepository repo;
  const GetSharedDocuments(this.repo);
  @override
  Future<Either<Failure, List<SharedFile>>> call(String roomId) =>
      repo.getSharedDocuments(roomId);
}

/// Params: the user's uid. `Right(null)` when no number is saved.
class GetPhoneNumber implements UseCase<String?, String> {
  final PrivateChatRepository repo;
  const GetPhoneNumber(this.repo);
  @override
  Future<Either<Failure, String?>> call(String uid) =>
      repo.getPhoneNumber(uid);
}
