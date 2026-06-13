import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Constents/AppConstents.dart';
import '../../Constents/AppStyles.dart';

class ButtonWidgets extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;

  ButtonWidgets({super.key, required this.onTap, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 65,
        width: double.infinity,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.boxColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            buttonText,
            style: AppStyles.goalTextStyle,
          ),
        ),
      ),
    );
  }
}
