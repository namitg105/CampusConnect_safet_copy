import 'package:flutter/material.dart';
import 'recent_chats_model.dart';

class ChatSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const ChatSearchBar({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE9ECF5)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
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
          //const Icon(Icons.search, size: 20, color: Color(0xFFB0B6C7)),
          const SizedBox(width: 18),
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF202236),
      ),
    );
  }
}

class OnlineIndicator extends StatelessWidget {
  final Color color;
  const OnlineIndicator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.85,
      right: 0.85,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class AvatarWithStatus extends StatelessWidget {
  final ConversationData data;

  const AvatarWithStatus({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final hasImage = data.imageUrl != null && data.imageUrl!.isNotEmpty;

    return SizedBox(
      width: width * 0.11,
      height: width * 0.11,
      child: Stack(
        children: [
          CircleAvatar(
            radius: width,
            backgroundColor: data.avatarColor,
            backgroundImage: hasImage ? NetworkImage(data.imageUrl!) : null,
            child: hasImage
                ? null
                : Text(
                    data.initials,
                    style: TextStyle(
                      fontSize: (width * 0.11) * 0.5,
                      fontWeight: FontWeight.w700,
                      color: data.avatarTextColor,
                    ),
                  ),
          ),
          if (data.isOnline)
            OnlineIndicator(color: const Color(0xFF2ECC71))
          else
            OnlineIndicator(color: const Color(0xFFB0B6C7)),
        ],
      ),
    );
  }
}
/*
class ChatList extends StatelessWidget {
  final List<ConversationData> conversations;
  final void Function(ConversationData)? onTap;

  const ChatList({super.key, required this.conversations, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: const Color(0x08000000),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final data = conversations[index];
          return ChatListItem(
            data: data,
            onTap: onTap != null ? () => onTap!(data) : null,
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            indent: 78,
            endIndent: 16,
            thickness: 1,
            color: Color(0xFFECECEC),
          );
        },
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onTap;

  const ChatListItem({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWithStatus(data: data),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.lastMessage ?? 'no message',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8EAA),
                      fontStyle: data.lastMessage == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (data.time != null)
              Text(
                data.time!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB0B0C8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
*/
///
///
///
/////////////////////////////////////////////////////
///
///
///

class ConversationTile extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onTap;

  const ConversationTile({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarWithStatus(data: data),
                const SizedBox(width: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.52,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        data.lastMessage ?? 'no message',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          fontStyle: data.lastMessage == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (data.time != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  data.time!,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UnreadConversationTile extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onTap;
  const UnreadConversationTile({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarWithStatus(data: data),
                const SizedBox(width: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.42,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        data.lastMessage ?? 'no message',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.time != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      data.time!,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                const SizedBox(height: 6.0),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF615BFF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${data.unreadCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

class ConversationsCard extends StatelessWidget {
  final List<ConversationData> conversations;
  final bool hasUnread;
  final void Function(ConversationData)? onTap;

  const ConversationsCard({
    super.key,
    required this.conversations,
    this.hasUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) return const SizedBox.shrink();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final data = conversations[index];
        if (hasUnread) {
          return UnreadConversationTile(
            data: data,
            onTap: onTap != null ? () => onTap!(data) : null,
          );
        }
        return ConversationTile(
          data: data,
          onTap: onTap != null ? () => onTap!(data) : null,
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 1,
          indent: 76.0,
          color: Color(0xFFE5E5E5),
        );
      },
    );
  }
}

class BlockedConversationTile extends StatelessWidget {
  final ConversationData data;
  final VoidCallback? onUnblock;

  const BlockedConversationTile({
    super.key,
    required this.data,
    this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onUnblock,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarWithStatus(data: data),
                const SizedBox(width: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        'Blocked',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: GestureDetector(
                onTap: onUnblock,
                child: const Text(
                  'Unblock',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6139ED),
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

class BlockedConversationsCard extends StatelessWidget {
  final List<ConversationData> conversations;
  final void Function(ConversationData)? onUnblock;

  const BlockedConversationsCard({
    super.key,
    required this.conversations,
    this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) return const SizedBox.shrink();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final data = conversations[index];
        return BlockedConversationTile(
          data: data,
          onUnblock: onUnblock != null ? () => onUnblock!(data) : null,
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 1,
          indent: 76.0,
          color: Color(0xFFE5E5E5),
        );
      },
    );
  }
}
