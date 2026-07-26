import 'package:flutter/material.dart';

class NotificationRichContent extends StatelessWidget {
  final String name;
  final String action;
  final String? highlight;
  final String? subtitle;
  final String timestamp;

  const NotificationRichContent({
    super.key,
    required this.name,
    required this.action,
    this.highlight,
    this.subtitle,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              TextSpan(
                text: ' $action ',
                style: const TextStyle(
                  color: Color(0xFF7E7E7E),
                ),
              ),
              if (highlight != null)
                TextSpan(
                  text: highlight,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C5CFA),
                  ),
                ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ],
        const SizedBox(height: 2),
        Text(
          timestamp,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}
