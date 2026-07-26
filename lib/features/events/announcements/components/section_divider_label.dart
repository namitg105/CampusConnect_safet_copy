import 'package:flutter/material.dart';

class SectionDividerLabel extends StatelessWidget {
  final String label;

  const SectionDividerLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE8E6F2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB0B0B0),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE8E6F2),
          ),
        ),
      ],
    );
  }
}
