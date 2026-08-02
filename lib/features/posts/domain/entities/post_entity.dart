import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String text;
  final List<String> votes;

  PollOption({required this.text, required this.votes});

  Map<String, dynamic> toJson() => {
        'text': text,
        'votes': votes,
      };

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
        text: json['text'] ?? json['option'] ?? '',
        votes: List<String>.from(json['votes'] ?? []),
      );
}

class PollData {
  final String question;
  final List<PollOption> options;

  PollData({required this.question, required this.options});

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes.length);

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options.map((o) => o.toJson()).toList(),
      };

  factory PollData.fromJson(Map<String, dynamic> json) => PollData(
        question: json['question'] ?? '',
        options: (json['options'] as List<dynamic>?)
                ?.map((o) => PollOption.fromJson(Map<String, dynamic>.from(o)))
                .toList() ??
            [],
      );
}

class PostEntity {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String collegeId;
  final int upvotes;
  final int commentCount;
  final String tag;
  final DateTime createdAt;
  final String? imageUrl;
  final String? mediaType; // 'image', 'video', 'document'
  final String? mediaName;
  final PollData? poll;

  PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.collegeId,
    required this.upvotes,
    required this.commentCount,
    required this.tag,
    required this.createdAt,
    this.imageUrl,
    this.mediaType,
    this.mediaName,
    this.poll,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'collegeId': collegeId,
      'upvotes': upvotes,
      'commentCount': commentCount,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'mediaType': mediaType,
      'mediaName': mediaName,
      'poll': poll?.toJson(),
    };
  }

  PostEntity copyWith({
    int? upvotes,
    int? commentCount,
    String? imageUrl,
    String? mediaType,
    String? mediaName,
    PollData? poll,
  }) {
    return PostEntity(
      id: id,
      title: title,
      body: body,
      authorId: authorId,
      authorName: authorName,
      collegeId: collegeId,
      upvotes: upvotes ?? this.upvotes,
      commentCount: commentCount ?? this.commentCount,
      tag: tag,
      createdAt: createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
      mediaName: mediaName ?? this.mediaName,
      poll: poll ?? this.poll,
    );
  }

  factory PostEntity.fromJson(Map<String, dynamic> json, String id) {
    final createdAtValue = json['createdAt'];
    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    PollData? pollData;
    if (json['poll'] != null && json['poll'] is Map<String, dynamic>) {
      pollData = PollData.fromJson(Map<String, dynamic>.from(json['poll']));
    }

    return PostEntity(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      collegeId: json['collegeId'] ?? '',
      upvotes: (json['upvotes'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? 0) as int,
      tag: json['tag'] ?? 'General',
      createdAt: createdAt,
      imageUrl: json['imageUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      mediaName: json['mediaName'] as String?,
      poll: pollData,
    );
  }
}
