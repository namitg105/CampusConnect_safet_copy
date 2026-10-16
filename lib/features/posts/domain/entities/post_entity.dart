/// One choice in a post's poll; [votes] holds the uids that picked it.
class PollOption {
  final String text;
  final List<String> votes;

  const PollOption({required this.text, required this.votes});
}

class PollData {
  final String question;
  final List<PollOption> options;

  const PollData({required this.question, required this.options});

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes.length);

  /// Single-choice poll: picking an option moves the user's vote there;
  /// picking the option they already chose removes their vote.
  PollData toggleVote({required String optionText, required String uid}) {
    final alreadyChosen =
        options.any((o) => o.text == optionText && o.votes.contains(uid));
    return PollData(
      question: question,
      options: options.map((opt) {
        final votes = List<String>.from(opt.votes)..remove(uid);
        if (opt.text == optionText && !alreadyChosen) votes.add(uid);
        return PollOption(text: opt.text, votes: votes);
      }).toList(),
    );
  }
}

/// A campus feed post. Pure Dart: Firestore mapping lives in `PostModel`.
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

  const PostEntity({
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
}
