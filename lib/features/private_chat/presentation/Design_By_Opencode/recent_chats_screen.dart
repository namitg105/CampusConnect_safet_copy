import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/private-chat-services/user_friend_add.dart';
import '../../domain/repos/chat_controller.dart';
import '../Design_By_Opencode_2/chat_screen.dart';
import 'recent_chats_model.dart';
import 'recent_chats_components.dart';

class RecentChatsScreen extends StatefulWidget {
  final String searchQuery;
  final int selectedTab;

  const RecentChatsScreen({
    super.key,
    this.searchQuery = '',
    this.selectedTab = 0,
  });

  @override
  State<RecentChatsScreen> createState() => _RecentChatsScreenState();
}

class _RecentChatsScreenState extends State<RecentChatsScreen> {
  late ChatController _chatController;
  late UserController _userController;

  List<ConversationData> _activeConversations = [];
  List<ConversationData> _unreadConversations = [];
  List<ConversationData> _blockedConversations = [];
  bool _isLoading = true;
  String? _currentUid;

  StreamSubscription? _friendsSub;
  StreamSubscription? _roomsSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _blockedSub;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    _userController = Get.find<UserController>();

    _currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (_currentUid != null) {
      _userController.listenToFriendsList(_currentUid!);
      _userController.listenToBlockedUsers(_currentUid!);
      _chatController.listenToChatRooms(_currentUid!);
    }

    _friendsSub = _userController.friendsList.listen((_) => _rebuild());
    _roomsSub = _chatController.chatRooms.listen((_) => _rebuild());
    _statusSub = _userController.friendStatuses.listen((_) => _rebuild());
    _blockedSub = _userController.blockedUids.listen((_) => _rebuild());

    WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild());
  }

  @override
  void didUpdateWidget(covariant RecentChatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedTab != widget.selectedTab) {
      _rebuild();
    }
  }

  @override
  void dispose() {
    _friendsSub?.cancel();
    _roomsSub?.cancel();
    _statusSub?.cancel();
    _blockedSub?.cancel();
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    _mergeData();
    _isLoading = false;
  }

  String _generateRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _mergeData() {
    final friends = _userController.friendsList;
    final rooms = _chatController.chatRooms;
    final blocked = _userController.blockedUids;

    final roomsMap = <String, Map<String, dynamic>>{};
    for (final room in rooms) {
      roomsMap[room['id'] as String] = room;
    }

    final active = <ConversationData>[];
    final unread = <ConversationData>[];
    final blockedList = <ConversationData>[];

    final query = widget.searchQuery.toLowerCase();

    for (final friend in friends) {
      if (query.isNotEmpty && !friend.name.toLowerCase().contains(query)) {
        continue;
      }

      final roomId = _generateRoomId(_currentUid!, friend.uid);
      final room = roomsMap[roomId];

      final isOnline = _userController.isFriendOnline(friend.uid);
      final unreadCount =
          room != null ? (room['unreadCount_$_currentUid'] as int? ?? 0) : 0;

      final ts = room?['lastMessageTimestamp'] as Timestamp?;
      final time = _formatTimestamp(ts);

      final isBlocked = blocked.contains(friend.uid);

      final data = ConversationData(
        uid: friend.uid,
        chatRoomId: roomId,
        imageUrl: friend.imageURL,
        name: friend.name,
        initials: _initials(friend.name),
        avatarColor: _avatarColor(friend.uid),
        lastMessage: room?['lastMessage'] as String?,
        time: time.isNotEmpty ? time : null,
        isOnline: isOnline,
        unreadCount: isBlocked ? 0 : unreadCount,
        isBlocked: isBlocked,
      );

      if (isBlocked) {
        blockedList.add(data);
      } else if (unreadCount > 0) {
        unread.add(data);
      } else {
        active.add(data);
      }
    }

    setState(() {
      _activeConversations = active;
      _unreadConversations = unread;
      _blockedConversations = blockedList;
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _avatarColor(String uid) {
    const colors = [
      Color(0xFFE9E3FF),
      Color(0xFFFFE2EC),
      Color(0xFFDDF8EA),
      Color(0xFFDCEAFF),
      Color(0xFFFFF1C8),
    ];
    return colors[uid.hashCode.abs() % colors.length];
  }

  void _onFriendTap(ConversationData data) async {
    if (_currentUid == null) return;

    final roomId = await _chatController.getOrCreateChatRoom(
      _currentUid!,
      data.uid,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: roomId,
          currentUid: _currentUid!,
          friendUid: data.uid,
          friendName: data.name,
          friendInitials: data.initials,
          friendAvatarColor: data.avatarColor,
          friendImageUrl: data.imageUrl,
        ),
      ),
    );
  }

  void _onUnblock(ConversationData data) async {
    if (_currentUid == null) return;
    final roomId = _generateRoomId(_currentUid!, data.uid);
    await _userController.unblockUser(data.uid, roomId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildTabContent();
  }

  Widget _buildTabContent() {
    switch (widget.selectedTab) {
      case 0:
        return _buildFriendsTab();
      case 1:
        return _buildBlockedTab();
      default:
        return _buildFriendsTab();
    }
  }

  Widget _buildFriendsTab() {
    if (_activeConversations.isEmpty && _unreadConversations.isEmpty) {
      return _buildEmptyState('No conversations found');
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        if (_activeConversations.isNotEmpty) ...[
          ..._activeConversations.map((data) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ChatCard(
                  data: data,
                  onTap: () => _onFriendTap(data),
                ),
              )),
        ],
        if (_unreadConversations.isNotEmpty) ...[
          const SectionTitle(title: 'UNREAD MESSAGES'),
          ..._unreadConversations.map((data) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: UnreadChatCard(
                  data: data,
                  onTap: () => _onFriendTap(data),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildBlockedTab() {
    if (_blockedConversations.isEmpty) {
      return _buildEmptyState('No blocked users');
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: _blockedConversations.length,
      itemBuilder: (context, index) {
        final data = _blockedConversations[index];
        return BlockedChatCard(
          data: data,
          onUnblock: () => _onUnblock(data),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 14);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
          ),
        ),
      ),
    );
  }
}
