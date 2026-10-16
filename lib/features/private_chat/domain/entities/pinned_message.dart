/// The single pinned message of a chat room.
class PinnedMessage {
  final DateTime pinnedMessageTimestamp;
  final String pinnedMessageId;
  final String pinnedMessageContent;
  final String pinnedBy;

  const PinnedMessage({
    required this.pinnedMessageTimestamp,
    required this.pinnedMessageId,
    required this.pinnedMessageContent,
    required this.pinnedBy,
  });

  /// Rooms are created with an empty placeholder pin.
  bool get isEmpty => pinnedMessageContent.isEmpty;
}
