import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../events/notifications/models/notification_model.dart';
import '../../../events/notifications/services/notification_service.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

/// All Firestore access for posts, votes, polls and comments.
abstract interface class PostRemoteDataSource {
  Future<void> createPost(PostEntity post);
  Future<List<PostModel>> getCollegeFeed(String collegeId);
  Future<List<PostModel>> getTopVotedPosts(String collegeId);
  Future<PostModel?> getPostById(String postId);
  Future<void> deletePost(String postId);
  Future<void> upvotePost(String postId, String userId);
  Future<void> downvotePost(String postId, String userId);
  Future<Map<String, int>> getUserVotesForPosts(
      String userId, List<String> postIds);
  Future<void> updatePoll(String postId, PollData poll);
  Future<void> addComment(CommentEntity comment);
  Future<List<CommentModel>> getComments(String postId);
  Future<void> deleteComment(String postId, String commentId, String userId);
  Future<void> toggleCommentLike(
      String postId, String commentId, String userId);
  Future<Map<String, bool>> getUserLikedComments(
      String postId, String userId, List<String> commentIds);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;
  const PostRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _posts =>
      firestore.collection('posts');

  DocumentReference<Map<String, dynamic>> _comment(
          String postId, String commentId) =>
      _posts.doc(postId).collection('comments').doc(commentId);

  Future<List<PostModel>> _collegePosts(String collegeId) async {
    final snapshot =
        await _posts.where('collegeId', isEqualTo: collegeId).get();
    return snapshot.docs
        .map((doc) => PostModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> createPost(PostEntity post) async {
    final docRef = await _posts.add(PostModel.toJson(post));

    // Fan-out notification is best-effort: the post already exists.
    try {
      final authorDoc =
          await firestore.collection('users').doc(post.authorId).get();
      final authorName = authorDoc.data()?['name'] ?? 'Someone';
      await NotificationService.notifyAllUsers(
        type: NotificationType.newPost,
        title: '$authorName posted a new update',
        description: post.title,
        subtitle: docRef.id,
        targetId: docRef.id,
      );
    } catch (e) {
      debugPrint('Failed to send notification for post: $e');
    }
  }

  @override
  Future<List<PostModel>> getCollegeFeed(String collegeId) async {
    final posts = await _collegePosts(collegeId);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  @override
  Future<List<PostModel>> getTopVotedPosts(String collegeId) async {
    final posts = await _collegePosts(collegeId);
    posts.sort((a, b) {
      if (b.upvotes != a.upvotes) return b.upvotes.compareTo(a.upvotes);
      return b.createdAt.compareTo(a.createdAt);
    });
    return posts;
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    final doc = await _posts.doc(postId).get();
    if (!doc.exists) return null;
    return PostModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<void> deletePost(String postId) => _posts.doc(postId).delete();

  @override
  Future<void> upvotePost(String postId, String userId) =>
      _castVote(postId, userId, 1);

  @override
  Future<void> downvotePost(String postId, String userId) =>
      _castVote(postId, userId, -1);

  /// [value] is 1 (up) or -1 (down). In one transaction:
  /// - same vote again  -> remove it
  /// - opposite vote    -> flip it (counter moves by 2)
  /// - no vote yet      -> add it
  Future<void> _castVote(String postId, String userId, int value) async {
    final postRef = _posts.doc(postId);
    await firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw const ServerException('Post not found');
      }

      final voteRef = postRef.collection('votes').doc(userId);
      final voteSnapshot = await transaction.get(voteRef);
      var upvotes = ((postSnapshot.data()?['upvotes'] ?? 0) as num).toInt();

      if (voteSnapshot.exists) {
        final existing =
            ((voteSnapshot.data()?['voteValue'] ?? 0) as num).toInt();
        if (existing == value) {
          upvotes -= value;
          transaction.delete(voteRef);
        } else if (existing == -value) {
          upvotes += 2 * value;
          transaction
              .set(voteRef, {'voteValue': value, 'votedAt': Timestamp.now()});
        }
      } else {
        upvotes += value;
        transaction
            .set(voteRef, {'voteValue': value, 'votedAt': Timestamp.now()});
      }

      transaction.update(postRef, {'upvotes': upvotes});
    });
  }

  @override
  Future<Map<String, int>> getUserVotesForPosts(
      String userId, List<String> postIds) async {
    final votes = <String, int>{};
    if (userId.isEmpty || postIds.isEmpty) return votes;

    await Future.wait(postIds.map((postId) async {
      try {
        final voteDoc =
            await _posts.doc(postId).collection('votes').doc(userId).get();
        votes[postId] = voteDoc.exists
            ? ((voteDoc.data()?['voteValue'] ?? 0) as num).toInt()
            : 0;
      } catch (e) {
        debugPrint('Error fetching vote for post $postId: $e');
        votes[postId] = 0;
      }
    }));
    return votes;
  }

  @override
  Future<void> updatePoll(String postId, PollData poll) =>
      _posts.doc(postId).update({'poll': PostModel.pollToJson(poll)});

  @override
  Future<void> addComment(CommentEntity comment) async {
    final postRef = _posts.doc(comment.postId);
    final commentRef =
        await postRef.collection('comments').add(CommentModel.toJson(comment));
    await postRef.update({'commentCount': FieldValue.increment(1)});
    await commentRef.update({'id': commentRef.id});

    // Tell the post author (best-effort, never about their own comment).
    try {
      final postDoc = await postRef.get();
      final postAuthorId = postDoc.data()?['authorId'] ?? '';
      if (postAuthorId.isNotEmpty && postAuthorId != comment.authorId) {
        final commenterDoc =
            await firestore.collection('users').doc(comment.authorId).get();
        final commenterName = commenterDoc.data()?['name'] ?? 'Someone';
        await NotificationService.createNotification(
          recipientId: postAuthorId,
          type: NotificationType.postCommented,
          title: '$commenterName commented on your post',
          description: comment.text,
          subtitle: comment.postId,
        );
      }
    } catch (e) {
      debugPrint('Failed to send comment notification: $e');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    final snapshot = await _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => CommentModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> deleteComment(
      String postId, String commentId, String userId) async {
    final commentRef = _comment(postId, commentId);
    final snapshot = await commentRef.get();
    if (!snapshot.exists) return;

    if ((snapshot.data()?['authorId'] ?? '') != userId) {
      throw const ServerException('You can only delete your own comments');
    }

    final batch = firestore.batch()
      ..delete(commentRef)
      ..update(_posts.doc(postId), {'commentCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  @override
  Future<void> toggleCommentLike(
      String postId, String commentId, String userId) async {
    final commentRef = _comment(postId, commentId);
    final likeRef = commentRef.collection('likes').doc(userId);

    await firestore.runTransaction((transaction) async {
      final commentSnapshot = await transaction.get(commentRef);
      if (!commentSnapshot.exists) {
        throw const ServerException('Comment not found');
      }

      final likeSnapshot = await transaction.get(likeRef);
      var likes = ((commentSnapshot.data()?['likes'] ?? 0) as num).toInt();

      if (likeSnapshot.exists) {
        likes = likes - 1 < 0 ? 0 : likes - 1;
        transaction.delete(likeRef);
      } else {
        likes += 1;
        transaction
            .set(likeRef, {'userId': userId, 'createdAt': Timestamp.now()});
      }
      transaction.update(commentRef, {'likes': likes});
    });
  }

  @override
  Future<Map<String, bool>> getUserLikedComments(
      String postId, String userId, List<String> commentIds) async {
    final liked = <String, bool>{};
    if (userId.isEmpty || commentIds.isEmpty) return liked;

    await Future.wait(commentIds.map((commentId) async {
      try {
        final likeDoc = await _comment(postId, commentId)
            .collection('likes')
            .doc(userId)
            .get();
        liked[commentId] = likeDoc.exists;
      } catch (e) {
        debugPrint('Error fetching like for comment $commentId: $e');
        liked[commentId] = false;
      }
    }));
    return liked;
  }
}
