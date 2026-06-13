import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Constents/AppConstents.dart';

class NarrowContainer extends StatelessWidget {
  final bool isLightMode;
  const NarrowContainer({
    super.key,
    required this.isLightMode
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.containerHeights,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLightMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.containerBorderRadius),
          bottomRight: Radius.circular(AppConstants.profileContainerBorderRadius),
        ),
      ),
    );
  }
}