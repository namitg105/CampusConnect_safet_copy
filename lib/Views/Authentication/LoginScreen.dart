import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Views/Authentication/SingUpScreen.dart';
import 'package:noteswap/Widgets/Buttons/BackWidgets.dart';
import '../../Constents/AppConstents.dart';
import '../../Widgets/Buttons/BottomButton.dart';
import '../../Widgets/Buttons/ButtonWidgets.dart';
import '../../Widgets/DividerWidgets.dart';
import '../../Widgets/InputWidgets.dart';
import '../../Widgets/LogingHeadlines.dart';
import '../../Widgets/Buttons/SocialButton.dart';
import '../ProfileScreen.dart';

class LoginScreen extends StatelessWidget {
    final void Function()? togglePages;

  LoginScreen({super.key,required this.togglePages});

  final TextEditingController passwordController = TextEditingController();
  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightModeController.isLightMode.value ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: lightModeController.isLightMode.value ? Colors.white : Colors.black,
          leading: BackWidget(
            onTap:(){}/* Get.to(/*removed login screen for now  */);*/
,
            imagePath: AppConstants.backBlackIcon,
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 268,
                width: double.infinity,
                color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LoginHeadlines(
                  headingText: AppConstants.loginTitle,
                  subHeadingText: AppConstants.loginSubtitle,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 670,
                decoration: BoxDecoration(
                  color: lightModeController.isLightMode.value ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SocialButton(
                            text: "Facebook",
                            asset: AppConstants.facebookIcon,
                            onPressed: () {},
                          ),
                          SocialButton(
                            text: "Google",
                            asset: AppConstants.googleIcon,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DividerWidgets(),
                      const SizedBox(height: 20),
                      InputField(
                        hintText: AppConstants.nameHint,
                      ),
                      const SizedBox(height: 15),
                      InputField(
                        hintText: AppConstants.passwordHint,
                        isPassword: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: ButtonWidgets(
                          onTap: () {
                            Get.to(ProfileScreen());
                          },
                          buttonText: 'Log In',
                        ),
                      ),
                      const SizedBox(height: 5),
                      BottomButton(
                        onTap: () {
                          Get.to(SignUpScreen());
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
