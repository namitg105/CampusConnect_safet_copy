import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';
import '../entities/pinned_message.dart';

/// A file picked on the device to send in a 1-to-1 chat.
class LocalAttachment {
  final String path;
  final String name;
  const LocalAttachment({required this.path, required this.name});
}

/// What to send; reply fields are set when answering a message.
class OutgoingMessage {
  final String roomId;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final String? repliedMessageId;
  final String? repliedMessageContent;
  final String? repliedMessageSender;
  final String? repliedMessageType;

  /// True when the receiver is blocked: they must not get an unread badge.
  final bool skipUnreadIncrement;

  const OutgoingMessage({
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.type = MessageType.text,
    this.repliedMessageId,
    this.repliedMessageContent,
    this.repliedMessageSender,
    this.repliedMessageType,
    this.skipUnreadIncrement = false,
  });
}

/// 1-to-1 chat rooms, messages, pins and shared media.
abstract interface class PrivateChatRepository {
  Stream<Either<Failure, List<ChatRoomSummary>>> watchChatRooms(String uid);

  /// Creates the room (with its empty pin placeholder) if needed.
  Future<Either<Failure, String>> getOrCreateRoom(String uid1, String uid2);

  Stream<Either<Failure, List<ChatMessage>>> watchMessages(String roomId);

  /// `Right(null)` when nothing is pinned.
  Stream<Either<Failure, PinnedMessage?>> watchPinned(String roomId);

  Stream<Either<Failure, bool>> watchUserOnline(String uid);

  Future<Either<Failure, void>> markAsRead(String roomId, String uid);

  /// [attachment] (photo or document) is uploaded first when given.
  Future<Either<Failure, void>> sendMessage(OutgoingMessage message,
      {LocalAttachment? attachment});

  Future<Either<Failure, void>> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  });

  /// Replaces the message with "Deleted by <name>" and removes its files.
  Future<Either<Failure, void>> deleteMessage(
      String roomId, ChatMessage message, String currentUid);

  Future<Either<Failure, void>> pinMessage(
      String roomId, ChatMessage message, String pinnedByUid);

  Future<Either<Failure, void>> unpinMessage(String roomId);

  Future<Either<Failure, RoomDetails>> getRoomDetails(
      String roomId, String currentUid);

  Future<Either<Failure, List<String>>> getSharedImages(String roomId);

  Future<Either<Failure, List<SharedFile>>> getSharedDocuments(String roomId);

  /// `Right(null)` when the user has not set a phone number.
  Future<Either<Failure, String?>> getPhoneNumber(String uid);
}
