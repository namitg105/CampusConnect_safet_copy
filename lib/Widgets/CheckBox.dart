import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

import '../Constents/AppConstents.dart';

class CheckBox extends StatelessWidget {
  CheckBox({
    super.key,
    required this.onPressed,
    required this.isChecked,
  });


  final VoidCallback onPressed;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: context.isLightMode ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isChecked
            ? Icon(Icons.check, color: context.isLightMode ? Colors.black : Colors.white, size: AppConstants.iconSize)
            : null,
      ),
    );
  }
}
