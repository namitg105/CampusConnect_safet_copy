import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common_widgets.dart';

typedef OnEmojiSelected = void Function(String emoji);

class MessageContextBottomSheet {
  static void show({
    required BuildContext context,
    required String messageText,
    VoidCallback? onReply,
    VoidCallback? onPin,
    VoidCallback? onDelete,
    OnEmojiSelected? onReact,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContent(
        messageText: messageText,
        onReply: onReply,
        onPin: onPin,
        onDelete: onDelete,
        onReact: onReact,
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final String messageText;
  final VoidCallback? onReply;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final OnEmojiSelected? onReact;

  const _BottomSheetContent({
    required this.messageText,
    this.onReply,
    this.onPin,
    this.onDelete,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const _BottomSheetDragHandle(),
            const SizedBox(height: 18),
            _ReactionSelectorRow(onReact: onReact),
            const SizedBox(height: 18),
            const Divider(height: 24, thickness: 1, color: Color(0xFFECECEC)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final actions = [
                    _ActionData(
                      icon: Icons.reply,
                      label: 'Reply',
                      bgColor: const Color(0xFFE9E3FF),
                      onTap: () {
                        Navigator.pop(context);
                        onReply?.call();
                      },
                    ),
                    _ActionData(
                      icon: Icons.push_pin,
                      label: 'Pin message',
                      bgColor: const Color(0xFFFFF1C8),
                      onTap: () {
                        Navigator.pop(context);
                        onPin?.call();
                      },
                    ),
                    _ActionData(
                      icon: Icons.content_copy,
                      label: 'Copy text',
                      bgColor: const Color(0xFFDCEBFF),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: messageText));
                        Navigator.pop(context);
                        showSuccessSnackbar('Copied to clipboard');
                      },
                    ),
                  ];
                  return _ContextMenuTile(data: actions[index]);
                },
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Color(0xFFECECEC)),
            _DeleteMessageTile(onDelete: () {
              Navigator.pop(context);
              onDelete?.call();
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });
}

class _BottomSheetDragHandle extends StatelessWidget {
  const _BottomSheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 46,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFDAD9E8),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _ReactionBubble extends StatelessWidget {
  final String emoji;
  final VoidCallback? onTap;

  const _ReactionBubble({required this.emoji, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F8),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

class _ReactionSelectorRow extends StatelessWidget {
  final OnEmojiSelected? onReact;

  const _ReactionSelectorRow({this.onReact});

  @override
  Widget build(BuildContext context) {
    const emojis = ['👍', '🖤', '😂', '😮', '😢', '🔥'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...emojis.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ReactionBubble(
                    emoji: e,
                    onTap: () {
                      Navigator.pop(context);
                      onReact?.call(e);
                    },
                  ),
                )),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.add, size: 20, color: Color(0xFF8D8D8D)),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextMenuTile extends StatelessWidget {
  final _ActionData data;

  const _ContextMenuTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, size: 20, color: const Color(0xFF5E5E5E)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202020),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteMessageTile extends StatelessWidget {
  final VoidCallback? onDelete;

  const _DeleteMessageTile({this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDelete,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE7EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Delete message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE0002A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
