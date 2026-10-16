import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post_entity.dart';

/// Firestore mapping for `posts/{postId}`.
///
/// ```json
/// {
///   "title": "Badminton at 6?", "body": "...", "authorId": "uid1",
///   "authorName": "Namit", "collegeId": "nith.ac.in", "upvotes": 4,
///   "commentCount": 2, "tag": "Badminton", "createdAt": <Timestamp>,
///   "imageUrl": null, "mediaType": null, "mediaName": null,
///   "poll": {"question": "...", "options": [{"text": "Yes", "votes": ["uid1"]}]}
/// }
/// ```
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.authorId,
    required super.authorName,
    required super.collegeId,
    required super.upvotes,
    required super.commentCount,
    required super.tag,
    required super.createdAt,
    super.imageUrl,
    super.mediaType,
    super.mediaName,
    super.poll,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
    final createdAtValue = json['createdAt'];
    final DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    final pollJson = json['poll'];
    return PostModel(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      collegeId: json['collegeId'] ?? '',
      upvotes: ((json['upvotes'] ?? 0) as num).toInt(),
      commentCount: ((json['commentCount'] ?? 0) as num).toInt(),
      tag: json['tag'] ?? 'General',
      createdAt: createdAt,
      imageUrl: json['imageUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      mediaName: json['mediaName'] as String?,
      poll: pollJson is Map
          ? pollFromJson(Map<String, dynamic>.from(pollJson))
          : null,
    );
  }

  /// Document written when creating a post (the id is assigned by Firestore).
  static Map<String, dynamic> toJson(PostEntity post) {
    return {
      'title': post.title,
      'body': post.body,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'collegeId': post.collegeId,
      'upvotes': post.upvotes,
      'commentCount': post.commentCount,
      'tag': post.tag,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'imageUrl': post.imageUrl,
      'mediaType': post.mediaType,
      'mediaName': post.mediaName,
      'poll': post.poll == null ? null : pollToJson(post.poll!),
    };
  }

  static Map<String, dynamic> pollToJson(PollData poll) => {
        'question': poll.question,
        'options': poll.options
            .map((o) => {'text': o.text, 'votes': o.votes})
            .toList(),
      };

  static PollData pollFromJson(Map<String, dynamic> json) => PollData(
        question: json['question'] ?? '',
        options: (json['options'] as List<dynamic>?)
                ?.map((o) {
                  final opt = Map<String, dynamic>.from(o);
                  return PollOption(
                    text: opt['text'] ?? opt['option'] ?? '',
                    votes: List<String>.from(opt['votes'] ?? []),
                  );
                })
                .toList() ??
            [],
      );
}
