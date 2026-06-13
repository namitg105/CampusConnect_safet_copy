import 'package:flutter/material.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import '../../Widgets/ReusableWidgets.dart';

class OnboardingScreenTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReusableWidgets(imagePath: AppConstants.onboardingTwo, text: AppConstants.onboardingTextTwo,),
    );
  }
}
