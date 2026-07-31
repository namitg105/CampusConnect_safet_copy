import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/private-chat-services/user_friend_add.dart';
import '../../domain/repos/chat_controller.dart';
import '../common_widgets.dart';
import 'directory_components.dart';
import 'directory_model.dart';

class DirectoryScreen extends StatefulWidget {
  final String searchQuery;
  final VoidCallback? onGoToRequests;

  const DirectoryScreen({
    super.key,
    this.searchQuery = '',
    this.onGoToRequests,
  });

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  List<DirectoryUser> _filteredUsers = [];
  List<DirectoryUser> _allDirectoryUsers = [];
  bool _isLoading = true;
  int _displayCount = 5;

  late ChatController _chatController;
  late UserController _userController;

  @override
  void initState() {
    super.initState();
    _chatController = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    _userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid != null) {
      _chatController.listenToDirectory(currentUid);
      _userController.listenToFriendsList(currentUid);
      _userController.listenToFriendRequests(currentUid);
    }

    _chatController.usersDirectory.listen((_) => _rebuildFromData());
    _userController.friendsList.listen((_) => _rebuildFromData());
    _userController.sentRequestUids.listen((_) => _rebuildFromData());
    _userController.incomingRequestUids.listen((_) => _rebuildFromData());
    _chatController.isDirectoryLoading.listen((loading) {
      if (mounted) setState(() => _isLoading = loading);
    });
  }

  @override
  void didUpdateWidget(covariant DirectoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _rebuildFromData();
    }
  }

  void _rebuildFromData() {
    final friendUids = _userController.friendsList.map((u) => u.uid).toSet();
    final requestedUids = _userController.sentRequestUids.value;
    final incomingRequestUids = _userController.incomingRequestUids.value;

    final users = _chatController.usersDirectory.map((map) {
      return DirectoryUser.fromMap(
        map,
        isFollowing: friendUids.contains(map['uid']),
        hasRequested: requestedUids.contains(map['uid']),
        hasIncomingRequest: incomingRequestUids.contains(map['uid']),
      );
    }).toList();

    if (mounted) {
      setState(() {
        _allDirectoryUsers = users;
        _applyFilters();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    List<DirectoryUser> result = _allDirectoryUsers;

    final query = widget.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.username.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    result = result.where((u) => !u.isFollowing).toList();

    result.sort((a, b) {
      if (a.hasIncomingRequest && !b.hasIncomingRequest) return -1;
      if (!a.hasIncomingRequest && b.hasIncomingRequest) return 1;
      if (a.hasRequested && !b.hasRequested) return -1;
      if (!a.hasRequested && b.hasRequested) return 1;
      return 0;
    });

    if (result.length > _displayCount) {
      result = result.sublist(0, _displayCount);
    }

    _filteredUsers = result;
  }

  Future<void> _addFriend(DirectoryUser user) async {
    try {
      await _userController.sendFriendRequest(user.uid);
      if (mounted) {
        showSuccessSnackbar('Friend request sent to ${user.name}');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar('Failed to send request: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
          ),
        ),
      );
    }

    final totalFiltered = _getTotalFilteredCount();
    final hasMore = _filteredUsers.length < totalFiltered;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredUsers.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredUsers.length) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _displayCount += 5;
                _applyFilters();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show More',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B5CEB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color(0xFF5B5CEB),
                  ),
                ],
              ),
            ),
          );
        }
        final user = _filteredUsers[index];
        return DirectoryUserTile(
          user: user,
          onAdd: () => _addFriend(user),
          onGoToRequests: widget.onGoToRequests,
        );
      },
    );
  }

  int _getTotalFilteredCount() {
    List<DirectoryUser> result = _allDirectoryUsers;

    final query = widget.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.username.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    result = result.where((u) => !u.isFollowing).toList();

    return result.length;
  }
}
