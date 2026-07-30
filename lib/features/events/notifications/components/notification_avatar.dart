import 'package:flutter/material.dart';
import '../../../auth/domain/entities/app_user.dart';

class NotificationAvatar extends StatelessWidget {
  final AppUser? appUser;
  final IconData? actionIcon;
  final Color? actionColor;
  final Color fallbackColor;
  final String fallbackInitials;

  const NotificationAvatar({
    super.key,
    this.appUser,
    this.actionIcon,
    this.actionColor,
    this.fallbackColor = const Color(0xFFE9E3FF),
    this.fallbackInitials = '?',
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = appUser != null &&
        appUser!.isImageExists &&
        appUser!.imageURL.isNotEmpty;

    final initials = fallbackInitials.isNotEmpty
        ? fallbackInitials
        : (appUser != null && appUser!.name.trim().isNotEmpty
            ? _getInitials(appUser!.name)
            : '?');

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: fallbackColor,
            backgroundImage: hasImage ? NetworkImage(appUser!.imageURL) : null,
            child: hasImage
                ? null
                : Text(
                    initials,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textColor(fallbackColor),
                    ),
                  ),
          ),
          if (actionIcon != null)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: actionColor ?? const Color(0xFF7C5CFA),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  actionIcon,
                  size: 9,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return '?';
      final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.isEmpty) return '?';

      if (words.length >= 2) {
        final first = words[0].substring(0, 1);
        final second = words[1].substring(0, 1);
        return (first + second).toUpperCase();
      } else {
        return words[0].substring(0, 1).toUpperCase();
      }
    } catch (_) {
      return '?';
    }
  }

  Color _textColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF4E4EAA) : Colors.white;
  }
}
