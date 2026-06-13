import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Widgets/Buttons/BackWidgets.dart';
import '../../Constents/AppConstents.dart';
import '../../Constents/AppStyles.dart';
import '../../ViewModels/CheckboxViewModels.dart';
import '../../Widgets/Buttons/BottomButton.dart';
import '../../Widgets/Buttons/ButtonWidgets.dart';
import '../../Widgets/CheckBox.dart';
import '../../Widgets/DividerWidgets.dart';
import '../../Widgets/InputWidgets.dart';
import '../../Widgets/LogingHeadlines.dart';
import '../../Widgets/Buttons/SocialButton.dart';
import 'LoginScreen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController passwordController = TextEditingController();
  final CheckBoxController controller = Get.put(CheckBoxController());
  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        appBar: AppBar(
          backgroundColor: lightModeController.isLightMode.value ? Colors.white : Colors.black,
          leading: BackWidget(onTap: () {}, imagePath: AppConstants.backBlackIcon,),
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
                  headingText: AppConstants.signupTitle,
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
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
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 15),
                      InputField(
                        hintText: AppConstants.emailHint,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 15),
                      InputField(
                        hintText: AppConstants.passwordHint,
                        keyboardType: TextInputType.text,
                        isPassword: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Obx(() => CheckBox(
                              onPressed: controller.toggleCheckbox,
                              isChecked: controller.isChecked.value,
                            )),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                AppConstants.termsText,
                                style: AppStyles.normalText.copyWith(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ButtonWidgets(
                          onTap: () {},
                          buttonText: AppConstants.createAccountText,
                        ),
                      ),
                      BottomButton(
                        onTap: () {
                          Get.to(LoginScreen());
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
