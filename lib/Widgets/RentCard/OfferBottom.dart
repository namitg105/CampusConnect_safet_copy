import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

class OfferBottom extends StatelessWidget {
  final Widget? title;

  OfferBottom({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Row(
        children: [
          Expanded(
            child: Text(
              "Computation of \nMathematics",
              style: TextStyle(
                color: context.isLightMode ? Colors.white : Colors.black,
                fontSize: 24,
              ),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 8),
          if (title != null) title! else const SizedBox(),
        ],
      ),
    );
  }
}
