import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common_widgets.dart';
import 'chat_details_model.dart';
import 'phoneDialer.dart';
import 'full_screen_image.dart';

class ChatDetailsAppBar extends StatelessWidget {
  const ChatDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Chat Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class AvatarWithOnlineStatus extends StatelessWidget {
  final String initials;
  final Color avatarColor;
  final bool isOnline;

  const AvatarWithOnlineStatus({
    super.key,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: avatarColor,
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF5CC9A6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final String initials;
  final Color avatarColor;
  final bool isOnline;
  final String statusText;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
    this.statusText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 22),
        AvatarWithOnlineStatus(
          initials: initials,
          avatarColor: avatarColor,
          isOnline: isOnline,
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202020),
          ),
        ),
        const SizedBox(height: 8),
        if (statusText.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF14B414),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF55B96B),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFEAE4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6B4EFF), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  final String friendUid;
  final String friendName;
  final String lastMessage;
  final DateTime? createdAt;
  final String roomId;
  final String currentUid;
  final bool isBlocked;
  final VoidCallback? onBlock;

  const QuickActionsRow({
    super.key,
    required this.friendUid,
    required this.friendName,
    required this.lastMessage,
    required this.createdAt,
    required this.roomId,
    required this.currentUid,
    this.isBlocked = false,
    this.onBlock,
  });

  void _showInfoDialog(BuildContext context) {
    final createdStr = createdAt != null
        ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} ${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}'
        : 'Unknown';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('Room Info', style: TextStyle(color: Color(0xFF5A3FFF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Name: $friendName'),
            const SizedBox(height: 8),
            Text(
                'Room ID: ${roomId.length > 10 ? '${roomId.substring(0, 5)}...${roomId.substring(roomId.length - 5)}' : roomId}'),
            const SizedBox(height: 8),
            Text('Last message: $lastMessage'),
            const SizedBox(height: 8),
            Text('Created: $createdStr'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          QuickActionButton(
            icon: Icons.message_outlined,
            label: 'Message',
            onTap: () => Navigator.pop(context),
          ),
          QuickActionButton(
            icon: Icons.call_outlined,
            label: 'Call',
            onTap: () async {
              try {
                await PhoneDialer().dial(friendUid);
              } catch (e) {
                if (context.mounted) {
                  showErrorSnackbar('Phone number not set');
                }
              }
            },
          ),
          QuickActionButton(
            icon: Icons.info_outline,
            label: 'Info',
            onTap: () => _showInfoDialog(context),
          ),
          QuickActionButton(
            icon: isBlocked ? Icons.lock_open : Icons.block,
            label: isBlocked ? 'Unblock' : 'Block',
            onTap: onBlock,
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'See all',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202020),
          ),
        ),
        Text(
          actionLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A3FFF),
          ),
        ),
      ],
    );
  }
}

class SharedImagesGrid extends StatelessWidget {
  final List<String> imageUrls;
  final bool showAll;
  final VoidCallback onToggle;

  const SharedImagesGrid({
    super.key,
    required this.imageUrls,
    required this.showAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionHeader(title: 'Shared Images', actionLabel: ''),
            SizedBox(height: 12),
            Text(
              'No images',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A0A0),
              ),
            ),
          ],
        ),
      );
    }

    final displayUrls = showAll ? imageUrls : imageUrls.take(7).toList();
    final remaining = imageUrls.length - 7;
    final showRemaining = !showAll && remaining > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Shared Images'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount:
                showRemaining ? displayUrls.length + 1 : displayUrls.length,
            itemBuilder: (context, index) {
              if (showRemaining && index == displayUrls.length) {
                return GestureDetector(
                  onTap: onToggle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: const Color(0xFFECE7FB),
                        child: Center(
                          child: Text(
                            '+$remaining',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5A3FFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              final url = displayUrls[index];
              return GestureDetector(
                onTap: () => Get.to(() => FullScreenImage(imageUrl: url)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFE8E0FF),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8E0FF),
                          child: const Icon(Icons.broken_image,
                              color: Color(0xFF5A3FFF)),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SharedDocumentsList extends StatelessWidget {
  final List<SharedDocument> documents;
  final bool showAll;
  final VoidCallback onToggle;

  const SharedDocumentsList({
    super.key,
    required this.documents,
    required this.showAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionHeader(title: 'Shared Documents', actionLabel: ''),
            SizedBox(height: 12),
            Text(
              'No documents',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A0A0),
              ),
            ),
          ],
        ),
      );
    }

    final displayDocs = showAll ? documents : documents.take(5).toList();
    final remaining = documents.length - 5;
    final showRemaining = !showAll && remaining > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Shared Documents'),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                showRemaining ? displayDocs.length + 1 : displayDocs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFEFEFEF)),
            itemBuilder: (context, index) {
              if (showRemaining && index == displayDocs.length) {
                return GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECE7FB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.folder_open,
                            size: 20,
                            color: Color(0xFF5A3FFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '+$remaining remaining',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5A3FFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final doc = displayDocs[index];
              return DocumentTile(
                document: doc,
                onTap: () => _openDocument(doc.url),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class DocumentTile extends StatelessWidget {
  final SharedDocument document;
  final VoidCallback? onTap;

  const DocumentTile({
    super.key,
    required this.document,
    this.onTap,
  });

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insert_drive_file,
                size: 20,
                color: Color(0xFF5A3FFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202020),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(document.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA0A0A0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF5A3FFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_downward,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
