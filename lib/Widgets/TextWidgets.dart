import 'package:flutter/material.dart';

class DetailItemWidget extends StatelessWidget {
  final String text;
  final bool isLightMode;

  const DetailItemWidget({
    super.key,
    required this.text,
    required this.isLightMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isLightMode ? Colors.black : Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 4,
              color: isLightMode ? Colors.white30 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
