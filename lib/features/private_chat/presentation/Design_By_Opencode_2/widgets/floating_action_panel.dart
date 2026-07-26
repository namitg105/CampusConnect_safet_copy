import 'package:flutter/material.dart';

class FloatingActionPanel extends StatelessWidget {
  final VoidCallback? onVideoCall;
  final VoidCallback? onVoiceCall;

  const FloatingActionPanel({
    super.key,
    this.onVideoCall,
    this.onVoiceCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionCircle(
            icon: Icons.videocam_outlined,
            onTap: onVideoCall,
          ),
          _ActionCircle(
            icon: Icons.call_outlined,
            onTap: onVoiceCall,
          ),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCircle({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF5A48E6),
          size: 22,
        ),
      ),
    );
  }
}
