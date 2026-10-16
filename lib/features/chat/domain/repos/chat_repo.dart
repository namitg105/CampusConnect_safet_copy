import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';

/// A file the user picked on the device (photo, video or document) to send.
class ChatAttachment {
  final String path;
  final String name;
  final String? extension;
  const ChatAttachment({required this.path, required this.name, this.extension});
}

enum MediaKind { image, video, document }

/// Community chat operations. Implemented in the data layer.
abstract interface class ChatRepo {
  /// Messages of a community, oldest first, live.
  Stream<Either<Failure, List<Message>>> watchMessages(String groupId);

  /// Sent as the logged-in user.
  Future<Either<Failure, void>> sendText(String groupId, String text);

  /// Images/videos are compressed before upload; documents are uploaded as-is.
  Future<Either<Failure, void>> sendMedia(
      String groupId, MediaKind kind, ChatAttachment file);

  Future<Either<Failure, void>> deleteMessage(
      String groupId, String messageId);

  Future<Either<Failure, void>> pinMessage(String groupId, String messageId);

  Future<Either<Failure, void>> unpinMessage(String groupId);
}
