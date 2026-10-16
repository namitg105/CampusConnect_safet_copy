import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:noteswap/core/theme/theme_context.dart';

class OfferHeader extends StatelessWidget {
  final Color color;
  OfferHeader({
    super.key,
    required this.color
  });


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Row(
        children: [
          Text(
            "CSE 2005",
            style: TextStyle(
              color: context.isLightMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 90,
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: const Text(
                "SCOPE",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
