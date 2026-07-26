import 'package:flutter/material.dart';
import 'recent_chats_model.dart';

const Color _primaryPurple = Color(0xFF6D4CFF);
const Color _lightPurple = Color(0xFFF3F0FF);
const Color _primaryText = Color(0xFF1F2937);
const Color _secondaryText = Color(0xFF6B7280);
const Color _border = Color(0xFFE5E7EB);
const Color _grey500 = Color(0xFF9CA3AF);
const Color _grey600 = Color(0xFF6B7280);
const Color _successGreen = Color(0xFF22C55E);
const Color _notificationRed = Color(0xFFEF4444);

const List<String> _picsumImages = [
  'https://picsum.photos/id/1005/200/200',
  'https://picsum.photos/id/1011/200/200',
  'https://picsum.photos/id/1027/200/200',
  'https://picsum.photos/id/64/200/200',
  'https://picsum.photos/id/65/200/200',
];

String getPicsumImage(String uid) {
  final index = uid.hashCode.abs() % _picsumImages.length;
  return _picsumImages[index];
}

class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasBadge;

  const HeaderIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: _secondaryText, size: 20),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _notificationRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileAvatarButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ProfileAvatarButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            'https://picsum.photos/id/1027/200/200',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _lightPurple,
              child: const Icon(Icons.person, color: _primaryPurple, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatsTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ChatsTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      _TabData(icon: Icons.people_outline, label: 'Friends'),
      _TabData(icon: Icons.block, label: 'Blocked'),
      _TabData(icon: Icons.mail_outline, label: 'Request'),
      _TabData(icon: Icons.search, label: 'Search'),
    ];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab.icon,
                    size: 22,
                    color: isSelected
                        ? _primaryPurple
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? _primaryPurple
                          : Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: isSelected ? 56 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _primaryPurple,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final String label;
  const _TabData({required this.icon, required this.label});
}

class SearchPeopleBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchTap;

  const SearchPeopleBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search people....',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: _grey500,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border, width: 1),
              ),
              child: const Icon(Icons.search, size: 20, color: _secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatStatisticsCard extends StatelessWidget {
  final int friendsCount;
  final int onlineCount;
  final int blockedCount;

  const ChatStatisticsCard({
    super.key,
    this.friendsCount = 0,
    this.onlineCount = 0,
    this.blockedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          _buildItem(
            icon: Icons.group_outlined,
            text: '$friendsCount friends',
          ),
          Container(
            width: 1,
            height: 36,
            color: _border,
          ),
          _buildItem(
            icon: Icons.local_fire_department,
            iconSize: 18,
            text: '$onlineCount online now',
          ),
          Container(
            width: 1,
            height: 36,
            color: _border,
          ),
          _buildItem(
            icon: Icons.block,
            text: '$blockedCount blocked',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String text,
    Color? iconColor,
    double iconSize = 18,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? _secondaryText,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _grey600,
            ),
          ),
        ],
      ),
    );
  }
}

class OnlineIndicator extends StatelessWidget {
  final bool isOnline;
  const OnlineIndicator({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isOnline ? _successGreen : _grey500,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
      ),
    );
  }
}

class AvatarWithStatus extends StatelessWidget {
  final ConversationData data;
  final double radius;

  const AvatarWithStatus({super.key, required this.data, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final hasImage = data.imageUrl != null && data.imageUrl!.isNotEmpty;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: data.avatarColor,
            backgroundImage: hasImage ? NetworkImage(data.imageUrl!) : null,
            child: hasImage
                ? null
                : Text(
                    data.initials,
                    style: TextStyle(
                      fontSize: radius * 0.6,
                      fontWeight: FontWeight.w700,
                      color: data.avatarTextColor,
                    ),
                  ),
          ),
          OnlineIndicator(isOnline: data.isOnline),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: _grey500,
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onTap;

  const ChatCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarWithStatus(data: data),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: _grey600,
                      fontStyle: data.lastMessage == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  if (data.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      data.time!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 90,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _primaryPurple, width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primaryPurple,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnreadChatCard extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onTap;

  const UnreadChatCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarWithStatus(data: data),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _grey600,
                    ),
                  ),
                  if (data.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      data.time!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'unread',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _primaryPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                CircleAvatar(
                  radius: 11,
                  backgroundColor: _primaryPurple,
                  child: Text(
                    '${data.unreadCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BlockedChatCard extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onUnblock;

  const BlockedChatCard({super.key, required this.data, this.onUnblock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUnblock,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarWithStatus(data: data),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Blocked',
                    style: TextStyle(
                      fontSize: 13,
                      color: _grey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onUnblock,
              child: const Text(
                'Unblock',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primaryPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
