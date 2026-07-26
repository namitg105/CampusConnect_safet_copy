import 'package:flutter/material.dart';

class NotificationSectionHeader extends StatelessWidget {
  final String label;
  final int newCount;

  const NotificationSectionHeader({
    super.key,
    required this.label,
    required this.newCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7E7E7E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFECECEC),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$newCount new',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7E7E7E),
          ),
        ),
      ],
    );
  }
}
