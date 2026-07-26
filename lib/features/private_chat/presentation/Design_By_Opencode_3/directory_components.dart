import 'package:flutter/material.dart';
import 'directory_model.dart';

const Color indigo = Color(0xFF5B5CEB);
const Color darkCharcoal = Color(0xFF1A1A1A);
const Color darkGray = Color(0xFF1F1F1F);
const Color textMuted = Color(0xFF9A9A9A);
const Color textGray = Color(0xFF7A7A7A);
const Color white = Color(0xFFFFFFFF);
const Color searchBackground = Color(0xFFF0F2F5);
const Color searchBorder = Color(0xFFE0E0E0);

class DirectoryHeader extends StatelessWidget {
  final String currentUserImageURL;
  final bool isCurrentUserImageExists;
  final String currentUserName;
  final VoidCallback? onLogout;

  const DirectoryHeader({
    super.key,
    this.currentUserImageURL = '',
    this.isCurrentUserImageExists = false,
    this.currentUserName = '',
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final initials = currentUserName.isNotEmpty
        ? currentUserName[0].toUpperCase()
        : '?';

    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 20),
          Text(
            'Directory',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: darkCharcoal,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE8E0FF),
                    backgroundImage: isCurrentUserImageExists &&
                            currentUserImageURL.isNotEmpty
                        ? NetworkImage(currentUserImageURL)
                        : null,
                    child: isCurrentUserImageExists &&
                            currentUserImageURL.isNotEmpty
                        ? null
                        : Text(
                            initials,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: darkGray,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF52D68A),
                        shape: BoxShape.circle,
                        border: Border.all(color: white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DirectorySearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const DirectorySearchField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: searchBorder, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Icon(Icons.search, size: 20, color: Color(0xFFB0B6C7)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B6C7),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class DirectoryFilterChips extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DirectoryFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding:
                EdgeInsets.only(right: index < labels.length - 1 ? 12 : 0),
            child: ChoiceChip(
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF6139ED).withValues(alpha: 1.0),
                      ),
                    ),
                  Text(labels[index]),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(index),
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6139ED).withValues(alpha: isSelected ? 1.0 : 0.5),
                letterSpacing: 0.2,
              ),
              backgroundColor: const Color(0xFFF5F5F5),
              selectedColor: const Color(0xFFF5F5F5),
              side: BorderSide(
                color: Color(0xFF6139ED).withValues(alpha: isSelected ? 0.6 : 0.25),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }),
      ),
    );
  }
}

class SuggestionsLabel extends StatelessWidget {
  const SuggestionsLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        'SUGGESTIONS',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Color(0xFFB0B0B0),
        ),
      ),
    );
  }
}

class UserAvatarWithStatus extends StatelessWidget {
  final DirectoryUser user;

  const UserAvatarWithStatus({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: user.avatarColor,
          backgroundImage:
              user.isImageExists && user.imageURL.isNotEmpty
                  ? NetworkImage(user.imageURL)
                  : null,
          child: user.isImageExists && user.imageURL.isNotEmpty
              ? null
              : Text(
                  user.initials,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
        ),
        if (user.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFF52D68A),
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class FollowStatusButton extends StatelessWidget {
  const FollowStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F7EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: Color(0xFF2F9E77)),
          const SizedBox(width: 4),
          const Text(
            'Following',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F9E77),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFriendButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddFriendButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF2EBFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          '+ Add',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: indigo,
          ),
        ),
      ),
    );
  }
}

class RequestedButton extends StatelessWidget {
  const RequestedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Requested',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD4A017),
        ),
      ),
    );
  }
}

class IncomingRequestButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const IncomingRequestButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Request',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1976D2),
          ),
        ),
      ),
    );
  }
}

class DirectoryUserTile extends StatefulWidget {
  final DirectoryUser user;
  final VoidCallback? onAdd;
  final VoidCallback? onGoToRequests;

  const DirectoryUserTile(
      {super.key, required this.user, this.onAdd, this.onGoToRequests});

  @override
  State<DirectoryUserTile> createState() => _DirectoryUserTileState();
}

class _DirectoryUserTileState extends State<DirectoryUserTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isPressed
            ? (Matrix4.identity()..scale(1.01))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    blurRadius: 24,
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.02),
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: SizedBox(
          height: 84,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatarWithStatus(user: widget.user),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                widget.user.isFollowing
                    ? const FollowStatusButton()
                    : widget.user.hasRequested
                        ? const RequestedButton()
                        : widget.user.hasIncomingRequest
                            ? IncomingRequestButton(
                                onPressed: widget.onGoToRequests)
                            : AddFriendButton(onPressed: widget.onAdd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTab(
              index: 0,
              icon: Icons.people_rounded,
              label: 'Directory',
              isActive: selectedIndex == 0,
            ),
            _buildTab(
              index: 1,
              icon: Icons.notifications_none_rounded,
              label: 'Requests',
              isActive: selectedIndex == 1,
            ),
            _buildTab(
              index: 2,
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chats',
              isActive: selectedIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isActive
                ? Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: indigo,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 22, color: white),
                  )
                : Icon(icon, size: 24, color: textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? darkCharcoal : textMuted,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
