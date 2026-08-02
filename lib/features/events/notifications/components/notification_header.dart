import 'package:flutter/material.dart';

class NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onClearAllTap;

  const NotificationHeader({
    super.key,
    required this.unreadCount,
    this.showBackButton = true,
    this.onBackTap,
    this.onClearAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                ],
              ),
              child: Icon(
                showBackButton ? Icons.arrow_back : Icons.settings_outlined,
                color: showBackButton ? Colors.black87 : Colors.grey,
                size: 22,
              ),
            ),
          ),
          const SizedBox.shrink(),
          TextButton(
            onPressed: onClearAllTap,
            child: const Text(
              'Clear all',
              style: TextStyle(
                color: Color(0xFF7C5CFA),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
