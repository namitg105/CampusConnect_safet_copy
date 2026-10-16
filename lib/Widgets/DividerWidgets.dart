import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

class DividerWidgets extends StatelessWidget {
  DividerWidgets({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.isLightMode ? Colors.white70: Colors.black,)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Or",
              style: TextStyle(color: context.isLightMode ? Colors.white70: Colors.black)),
        ),
        Expanded(child: Divider(color: context.isLightMode ? Colors.white70: Colors.black)),
      ],
    );
  }
}
