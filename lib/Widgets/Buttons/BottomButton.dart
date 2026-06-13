import 'package:flutter/material.dart';
import 'package:noteswap/Constents/AppConstents.dart';

import '../../Constents/AppStyles.dart';

class BottomButton extends StatelessWidget {
  final VoidCallback onTap;
  const BottomButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          AppConstants.haveAccount,
          style: AppStyles.normalText,
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: onTap,
          child: Text(
            AppConstants.signIn,
            style: AppStyles.boldUnderlinedText,
          ),
        ),
      ],
    );
  }
}
