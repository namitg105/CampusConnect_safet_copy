/// A friend request stored under `users/{uid}/friend_requests`.
class FriendRequest {
  final String fromUid;
  final String fromName;
  final String fromEmail;
  final String fromImageURL;
  final String status; // 'pending' | 'ignored'
  final DateTime timestamp;

  const FriendRequest({
    required this.fromUid,
    required this.fromName,
    required this.fromEmail,
    required this.fromImageURL,
    required this.status,
    required this.timestamp,
  });
}
