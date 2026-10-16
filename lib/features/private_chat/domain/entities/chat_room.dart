/// Summary of a 1-to-1 chat room, as shown in the Recent Chats list.
class ChatRoomSummary {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  /// uid -> unread messages for that participant.
  final Map<String, int> unreadCounts;

  const ChatRoomSummary({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCounts = const {},
  });

  int unreadFor(String uid) => unreadCounts[uid] ?? 0;

  /// Room ids are the two uids sorted and joined: "a_b".
  static String idFor(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }
}

/// Header info for the chat details screen.
class RoomDetails {
  final String participantName;
  final String lastMessage;
  final DateTime? createdAt;

  const RoomDetails({
    required this.participantName,
    required this.lastMessage,
    this.createdAt,
  });
}

/// A photo or document that was shared in a room.
class SharedFile {
  final String url;
  final String name;
  final DateTime timestamp;

  const SharedFile({
    required this.url,
    required this.name,
    required this.timestamp,
  });
}
