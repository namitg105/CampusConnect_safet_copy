import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/core/di/injection.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_2/chat_screen.dart';
import 'package:noteswap/features/chat/presentation/pages/chatPage.dart';
import 'package:noteswap/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:noteswap/features/posts/presentation/pages/post_detail_page.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/features/posts/data/post_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/downvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_by_tag_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_top_voted_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/upvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_votes_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_liked_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/admin_events/presentation/screens/AdminEvent.dart';

import 'models/notification_model.dart';
import 'components/notification_header.dart';
import 'components/notification_title_section.dart';
import 'components/notification_section_header.dart';
import 'components/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationData> _notifications = [];
  StreamSubscription? _notificationsSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
    _markNotificationsAsRead();
  }

  void _markNotificationsAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      final unreadSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      if (unreadSnapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print("Failed to mark notifications as read: $e");
    }
  }

  void _listenToNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
      return;
    }

    _notificationsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            
            NotificationType type;
            try {
              type = NotificationType.values.firstWhere(
                (e) => e.name == data['type'],
                orElse: () => NotificationType.postCommented,
              );
            } catch (_) {
              type = NotificationType.postCommented;
            }

            final Timestamp? ts = data['timestamp'] as Timestamp?;
            final DateTime dt = ts?.toDate() ?? DateTime.now();

            final senderId = data['senderId'] ?? '';
            final senderName = data['senderName'] ?? '';
            final senderImage = data['senderImage'] ?? '';
            final appUser = (senderName.isNotEmpty || senderId.isNotEmpty)
                ? AppUser(
                    uid: senderId,
                    email: '',
                    name: senderName,
                    collegeId: '',
                    imageURL: senderImage,
                  )
                : null;

            return NotificationData(
              id: doc.id,
              type: type,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              timestamp: dt,
              isRead: data['isRead'] ?? false,
              societyName: data['societyName'] ?? '',
              subtitle: data['subtitle'] ?? '',
              appUser: appUser,
            );
          }).toList();

          if (mounted) {
            setState(() {
              _notifications = list;
              _isLoading = false;
            });
          }
        }, onError: (err) {
          print("Failed to listen to notifications: $err");
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationData> get _todayNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => n.timestamp.isAfter(todayStart))
        .toList();
  }

  List<NotificationData> get _earlierNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => !n.timestamp.isAfter(todayStart))
        .toList();
  }

  void _onDelete(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e) {
      print('Failed to delete notification: $e');
    }
  }

  void _onClearAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Failed to clear notifications: $e');
    }
  }

  void _handleNotificationTap(NotificationData notification) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUid.isEmpty) return;

    if (notification.type == NotificationType.requestChatPrivate) {
      final targetRoomId = notification.subtitle ?? '';
      if (targetRoomId.isEmpty) return;
      
      final parts = targetRoomId.split('_');
      final friendUid = parts.firstWhere((p) => p != currentUid, orElse: () => '');
      if (friendUid.isEmpty) return;
      
      final friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendUid).get();
      if (!friendDoc.exists) return;
      final friendData = friendDoc.data() ?? {};
      final friendName = friendData['name'] ?? 'Friend';
      
      Get.to(() => ChatScreen(
        roomId: targetRoomId,
        currentUid: currentUid,
        friendUid: friendUid,
        friendName: friendName,
        friendInitials: friendName.isNotEmpty ? friendName[0].toUpperCase() : '?',
        friendAvatarColor: const Color(0xFF6139ED),
        friendImageUrl: friendData['profileImage'],
      ));
    } else if (notification.type == NotificationType.requestChatGroup) {
      final groupId = notification.subtitle ?? '';
      if (groupId.isEmpty) return;
      
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return;
      final groupData = groupDoc.data() ?? {};
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<ChatCubit>(
            create: (_) => sl<ChatCubit>(),
            child: ChatPage(
              groupId: groupId,
              groupName: groupData['name'] ?? 'Community Group',
            ),
          ),
        ),
      );
    } else if (notification.type == NotificationType.postCommented ||
               notification.type == NotificationType.newPost) {
      final postId = notification.subtitle ?? '';
      if (postId.isEmpty) return;
      
      final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      if (!postDoc.exists) return;
      
      final post = PostEntity.fromJson(postDoc.data()!, postDoc.id);
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
      final userData = userDoc.data() ?? {};
      final currentUser = AppUser(
        uid: currentUid,
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
        collegeId: userData['collegeId'] ?? '',
      );
      
      final postRepo = PostRepoImpl();
      final postController = PostController(
        createPostUseCase: CreatePostUseCase(repository: postRepo),
        getFeedUseCase: GetFeedUseCase(repository: postRepo),
        getFeedByTagUseCase: GetFeedByTagUseCase(repository: postRepo),
        getTopVotedPostsUseCase: GetTopVotedPostsUseCase(repository: postRepo),
        upvotePostUseCase: UpvotePostUseCase(repository: postRepo),
        downvotePostUseCase: DownvotePostUseCase(repository: postRepo),
        addCommentUseCase: AddCommentUseCase(repository: postRepo),
        getCommentsUseCase: GetCommentsUseCase(repository: postRepo),
        deleteCommentUseCase: DeleteCommentUseCase(repository: postRepo),
        toggleCommentLikeUseCase: ToggleCommentLikeUseCase(repository: postRepo),
        getUserVotesUseCase: GetUserVotesUseCase(repository: postRepo),
        deletePostUseCase: DeletePostUseCase(repository: postRepo),
        getUserLikedCommentsUseCase: GetUserLikedCommentsUseCase(repository: postRepo),
      );
      
      Get.to(() => PostDetailPage(
        post: post,
        controller: postController,
        currentUser: currentUser,
      ));
    } else if (notification.type == NotificationType.event) {
      Get.to(() => EventDetailsPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationHeader(
                unreadCount: _unreadCount,
                showBackButton: true,
                onBackTap: () => Navigator.pop(context),
                onClearAllTap: _onClearAll,
              ),
              const SizedBox(height: 26),
              NotificationTitleSection(totalCount: _notifications.length),
              const SizedBox(height: 26),
              Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildNotificationList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
          ),
        ),
      );
    }

    final today = _todayNotifications;
    final earlier = _earlierNotifications;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (today.isNotEmpty) ...[
          NotificationSectionHeader(
            label: 'TODAY',
            newCount: today.where((n) => !n.isRead).length,
          ),
          const SizedBox(height: 14),
          ...today.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _onDelete(n.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6139ED).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF6139ED),
                      size: 28,
                    ),
                  ),
                  child: NotificationCard(
                    notification: n,
                    onDelete: () => _onDelete(n.id),
                    onTap: () => _handleNotificationTap(n),
                  ),
                ),
              )),
        ],
        if (earlier.isNotEmpty) ...[
          if (today.isNotEmpty) const SizedBox(height: 12),
          NotificationSectionHeader(
            label: 'EARLIER',
            newCount: earlier.where((n) => !n.isRead).length,
          ),
          const SizedBox(height: 14),
          ...earlier.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _onDelete(n.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6139ED).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF6139ED),
                      size: 28,
                    ),
                  ),
                  child: NotificationCard(
                    notification: n,
                    onDelete: () => _onDelete(n.id),
                    onTap: () => _handleNotificationTap(n),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
