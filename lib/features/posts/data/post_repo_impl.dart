import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/domain/repos/post_repo.dart';

class PostRepoImpl implements PostRepo {
  final FirebaseFirestore firestore;

  PostRepoImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Day 1-2: Create a new post in the Firestore 'posts' collection
  @override
  Future<void> createPost(PostEntity post) async {
    final postsCollection = firestore.collection('posts');
    await postsCollection.add(post.toJson());
  }

  // Day 1-2: Fetch all posts from user's college, newest first
  @override
  Future<List<PostEntity>> getCollegeFeed(String collegeId) async {
    final querySnapshot = await firestore
        .collection('posts')
        .where('collegeId', isEqualTo: collegeId)
        .get();

    final posts = querySnapshot.docs
        .map((doc) => PostEntity.fromJson(doc.data(), doc.id))
        .toList();

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  // Day 3: Filter posts by both college AND tag
  // Example tags: "Badminton", "Seniors", "ExamHelp"
  @override
  Future<List<PostEntity>> getCollegeFeedByTag(
      String collegeId, String tag) async {
    final querySnapshot = await firestore
        .collection('posts')
        .where('collegeId', isEqualTo: collegeId)
        .where('tag', isEqualTo: tag)
        .get();

    final posts = querySnapshot.docs
        .map((doc) => PostEntity.fromJson(doc.data(), doc.id))
        .toList();

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  // Day 3: Fetch top voted posts in the college (sorted by upvotes)
  @override
  Future<List<PostEntity>> getTopVotedPosts(String collegeId) async {
    final querySnapshot = await firestore
        .collection('posts')
        .where('collegeId', isEqualTo: collegeId)
        .get();

    final posts = querySnapshot.docs
        .map((doc) => PostEntity.fromJson(doc.data(), doc.id))
        .toList();

    posts.sort((a, b) {
      if (b.upvotes != a.upvotes) {
        return b.upvotes.compareTo(a.upvotes);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return posts;
  }

  // Day 3: Fetch newest posts (same as getCollegeFeed, for consistency)
  @override
  Future<List<PostEntity>> getNewestPosts(String collegeId) async {
    return getCollegeFeed(collegeId);
  }

  // Day 6: User upvotes a post. Store vote in a subcollection & increment counter
  @override
  Future<void> upvotePost(String postId, String userId) async {
    final postRef = firestore.collection('posts').doc(postId);

    // Use a transaction to ensure atomicity:
    // 1. Check if user already voted
    // 2. Adjust vote count accordingly
    // 3. Save the vote record
    await firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception('Post not found');
      }

      final voteRef = postRef.collection('votes').doc(userId);
      final voteSnapshot = await transaction.get(voteRef);

      int currentUpvotes = (postSnapshot.data()?['upvotes'] ?? 0) as int;

      if (voteSnapshot.exists) {
        final existingVote = (voteSnapshot.data()?['voteValue'] ?? 0) as int;

        if (existingVote == 1) {
          // Already upvoted - remove vote
          currentUpvotes = (currentUpvotes - 1).clamp(0, double.infinity).toInt();
          transaction.delete(voteRef);
        } else if (existingVote == -1) {
          // Was downvoted - change to upvote
          currentUpvotes = (currentUpvotes + 2).toInt();
          transaction.set(voteRef, {'voteValue': 1, 'votedAt': Timestamp.now()});
        }
      } else {
        // No prior vote - add upvote
        currentUpvotes = currentUpvotes + 1;
        transaction.set(voteRef, {'voteValue': 1, 'votedAt': Timestamp.now()});
      }

      transaction.update(postRef, {'upvotes': currentUpvotes});
    });
  }

  // Day 6: User downvotes a post
  @override
  Future<void> downvotePost(String postId, String userId) async {
    final postRef = firestore.collection('posts').doc(postId);

    await firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception('Post not found');
      }

      final voteRef = postRef.collection('votes').doc(userId);
      final voteSnapshot = await transaction.get(voteRef);

      int currentUpvotes = (postSnapshot.data()?['upvotes'] ?? 0) as int;

      if (voteSnapshot.exists) {
        final existingVote = (voteSnapshot.data()?['voteValue'] ?? 0) as int;

        if (existingVote == -1) {
          // Already downvoted - remove vote
          currentUpvotes = (currentUpvotes + 1).toInt();
          transaction.delete(voteRef);
        } else if (existingVote == 1) {
          // Was upvoted - change to downvote
          currentUpvotes = (currentUpvotes - 2).clamp(0, double.infinity).toInt();
          transaction.set(voteRef, {'voteValue': -1, 'votedAt': Timestamp.now()});
        }
      } else {
        // No prior vote - add downvote
        currentUpvotes = (currentUpvotes - 1).clamp(0, double.infinity).toInt();
        transaction.set(voteRef, {'voteValue': -1, 'votedAt': Timestamp.now()});
      }

      transaction.update(postRef, {'upvotes': currentUpvotes});
    });
  }

  // Day 6: User removes their vote entirely
  @override
  Future<void> removeVote(String postId, String userId) async {
    final postRef = firestore.collection('posts').doc(postId);

    await firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception('Post not found');
      }

      final voteRef = postRef.collection('votes').doc(userId);
      final voteSnapshot = await transaction.get(voteRef);

      if (voteSnapshot.exists) {
        final voteValue = (voteSnapshot.data()?['voteValue'] ?? 0) as int;
        int currentUpvotes = (postSnapshot.data()?['upvotes'] ?? 0) as int;

        if (voteValue == 1) {
          currentUpvotes = (currentUpvotes - 1).clamp(0, double.infinity).toInt();
        } else if (voteValue == -1) {
          currentUpvotes = (currentUpvotes + 1).toInt();
        }

        transaction.delete(voteRef);
        transaction.update(postRef, {'upvotes': currentUpvotes});
      }
    });
  }

  @override
  Future<void> addComment(CommentEntity comment) async {
    final postRef = firestore.collection('posts').doc(comment.postId);
    final commentRef = await postRef.collection('comments').add(comment.toJson());
    await postRef.update({'commentCount': FieldValue.increment(1)});
    await commentRef.update({'id': commentRef.id});
  }

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    final snapshot = await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CommentEntity.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> deleteComment(String postId, String commentId, String userId) async {
    final commentRef = firestore.collection('posts').doc(postId).collection('comments').doc(commentId);
    final snapshot = await commentRef.get();
    if (!snapshot.exists) {
      return;
    }

    if ((snapshot.data()?['authorId'] ?? '') != userId) {
      throw Exception('You can only delete your own comments');
    }

    final batch = firestore.batch();
    batch.delete(commentRef);
    batch.update(firestore.collection('posts').doc(postId), {'commentCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  @override
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    final commentRef = firestore.collection('posts').doc(postId).collection('comments').doc(commentId);
    final likeRef = commentRef.collection('likes').doc(userId);
    final likeSnapshot = await likeRef.get();

    if (likeSnapshot.exists) {
      await likeRef.delete();
      return;
    }

    await likeRef.set({'userId': userId, 'createdAt': Timestamp.now()});
  }
}

