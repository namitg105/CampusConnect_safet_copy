import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/friends/friends_bloc.dart';
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
  // Rebuilt from FriendsBloc on every build.
  List<DirectoryUser> _filteredUsers = [];
  List<DirectoryUser> _allDirectoryUsers = [];
  bool _isLoading = true;
  int _displayCount = 5;

  @override
  void initState() {
    super.initState();
    // Everyone else in the app; friends and requests are already watched.
    context.read<FriendsBloc>().add(const DirectoryWatchRequested());
  }

  void _rebuildFromData(FriendsState friends) {
    final friendUids = friends.friends.map((u) => u.uid).toSet();
    final requestedUids = friends.sentRequestUids;
    final incomingRequestUids = friends.incomingRequestUids;

    _allDirectoryUsers = friends.directory.map((user) {
      return DirectoryUser.fromUser(
        user,
        isFollowing: friendUids.contains(user.uid),
        hasRequested: requestedUids.contains(user.uid),
        hasIncomingRequest: incomingRequestUids.contains(user.uid),
      );
    }).toList();
    _isLoading = !friends.directoryLoaded;
    _applyFilters();
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

  /// Result snackbar comes from the app-wide FriendsBloc listener.
  void _addFriend(DirectoryUser user) {
    context.read<FriendsBloc>().add(FriendRequestSent(user.uid, user.name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, friends) {
        _rebuildFromData(friends);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        );
      },
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
