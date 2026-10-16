import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/chat_room.dart';
import '../bloc/chat_rooms/chat_rooms_bloc.dart';
import '../bloc/friends/friends_bloc.dart';
import '../common_widgets.dart';
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
  // Rebuilt from FriendsBloc + ChatRoomsBloc on every build.
  List<ConversationData> _activeConversations = [];
  List<ConversationData> _unreadConversations = [];
  List<ConversationData> _blockedConversations = [];

  String? get _currentUid {
    final authState = context.read<AuthBloc>().state;
    return authState is Authenticated ? authState.user.uid : null;
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
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

  /// Joins friends with their room (last message, unread count) and sorts
  /// them into active / unread / blocked.
  void _mergeData(FriendsState friendsState, List<ChatRoomSummary> rooms) {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    final roomsById = {for (final room in rooms) room.id: room};
    final active = <ConversationData>[];
    final unread = <ConversationData>[];
    final blockedList = <ConversationData>[];
    final query = widget.searchQuery.toLowerCase();

    for (final AppUser friend in friendsState.friends) {
      if (query.isNotEmpty && !friend.name.toLowerCase().contains(query)) {
        continue;
      }

      final roomId = ChatRoomSummary.idFor(currentUid, friend.uid);
      final room = roomsById[roomId];
      final unreadCount = room?.unreadFor(currentUid) ?? 0;
      final time = _formatTimestamp(room?.lastMessageAt);
      final isBlocked = friendsState.isBlocked(friend.uid);

      final data = ConversationData(
        uid: friend.uid,
        chatRoomId: roomId,
        imageUrl: friend.imageURL,
        name: friend.name,
        initials: _initials(friend.name),
        avatarColor: _avatarColor(friend.uid),
        lastMessage: room?.lastMessage,
        time: time.isNotEmpty ? time : null,
        isOnline: friendsState.isOnline(friend.uid),
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

    _activeConversations = active;
    _unreadConversations = unread;
    _blockedConversations = blockedList;
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

  /// Identifies this tab when talking to the shared ChatRoomsBloc.
  int get _requesterId => identityHashCode(this);

  /// The room is created if needed; the listener in [build] opens it.
  void _onFriendTap(ConversationData data) {
    final currentUid = _currentUid;
    if (currentUid == null) return;
    context.read<ChatRoomsBloc>().add(
        ChatRoomOpenRequested(
          currentUid: currentUid,
          friendUid: data.uid,
          requesterId: _requesterId,
        ));
  }

  void _onUnblock(ConversationData data) {
    final currentUid = _currentUid;
    if (currentUid == null) return;
    context.read<FriendsBloc>().add(UserUnblockRequested(
          targetUid: data.uid,
          targetName: data.name,
          roomId: ChatRoomSummary.idFor(currentUid, data.uid),
        ));
  }

  void _openRoom(RoomToOpen room) {
    final currentUid = _currentUid;
    if (currentUid == null) return;
    final data = [
      ..._activeConversations,
      ..._unreadConversations,
      ..._blockedConversations,
    ].where((c) => c.uid == room.friendUid).firstOrNull;
    if (data == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: room.roomId,
          currentUid: currentUid,
          friendUid: data.uid,
          friendName: data.name,
          friendInitials: data.initials,
          friendAvatarColor: data.avatarColor,
          friendImageUrl: data.imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatRoomsBloc, ChatRoomsState>(
      // Both tabs share the bloc: only the tab that asked opens the room.
      listenWhen: (p, c) =>
          p.openId != c.openId && c.roomToOpen?.requesterId == _requesterId,
      listener: (context, state) => _openRoom(state.roomToOpen!),
      child: BlocListener<ChatRoomsBloc, ChatRoomsState>(
        listenWhen: (p, c) =>
            p.errorId != c.errorId && c.errorRequesterId == _requesterId,
        listener: (context, state) => showErrorSnackbar(state.error),
        child: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, friendsState) =>
              BlocBuilder<ChatRoomsBloc, ChatRoomsState>(
            builder: (context, roomsState) {
              if (!friendsState.friendsLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              _mergeData(friendsState, roomsState.rooms);
              return _buildTabContent();
            },
          ),
        ),
      ),
    );
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
