import 'package:flutter/material.dart';

class NotificationTitleSection extends StatelessWidget {
  final int unreadCount;

  const NotificationTitleSection({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Stay up to date with your community',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7E7E7E),
          ),
        ),
      ],
    );
  }
}
