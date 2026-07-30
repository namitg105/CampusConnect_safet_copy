import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/components/components.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/private_chat/presentation/common_widgets.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';

//------------------------------//

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({super.key, this.togglePages});

  @override
  State<RegisterPage> createState() => RegisterPageUi();
}

class RegisterPageUi extends State<RegisterPage> {
  //-------------------width & height-----------------------//
  late double width, height;
  late Splash_Widget_Components _splashAppWidget;
  late double imageWidthAdjustment;

  //-------------------form controller-----------------------//
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passTextController = TextEditingController();
  final confirmPassTextController = TextEditingController();
  bool hiddenText = true;
  bool confirmhiddenText = true;

  //-------------------image controller----------------------//
  final imagePath = "assets/images_register/register_girl_grouped_cropped.png";
  late AssetImage imageProvider;
  late double displayedHeight = 0.0;
  //-------------------form controller-----------------------//
  bool isChecked = false;

//register button pressed
  void register() {
    final email = emailTextController.text.trim();
    final name = nameTextController.text.trim();
    final pw = passTextController.text.trim();
    final confirmPw = confirmPassTextController.text.trim();

    if (email.isEmpty || pw.isEmpty || name.isEmpty) {
      showErrorSnackbar("Please complete all fields");
      return;
    }

    if (pw != confirmPw) {
      showErrorSnackbar("Passwords do not match");
      return;
    }

    if (!isChecked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Terms & Conditions Required",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            "Please check the terms and condition box to continue to the app.",
            style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF6139ED),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final authCubit = context.read<AuthCubit>();
    authCubit.register(name, email, pw);
  }

  @override
  void dispose() {
    passTextController.dispose();
    confirmPassTextController.dispose();
    nameTextController.dispose();
    emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    imageWidthAdjustment = width / 1.1; //width / 1.2
    _splashAppWidget = Splash_Widget_Components(width: width, height: height);

    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // This clears the navigation stack and safely lands them on MainPage
            Get.offAll(() => const MainPage());
          } else if (state is AuthError) {
            showErrorSnackbar(state.message);
          }
        },
        child: Scaffold(
          appBar: _splashAppWidget.AppBarDesign(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height * 0.025),
                Container(
                  width: width,
                  alignment: Alignment.center,
                  child: Image.asset(imagePath, width: imageWidthAdjustment),
                ),
                RegisterBoxDecoration(),
              ],
            ),
          ),
        ));
  }

  TextSpan _TextStyleWidget(
    String content, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextSpan(
      text: content,
      style: TextStyle(
        color: (color != null) ? color : Colors.black,
        fontSize: (fontSize != null) ? fontSize : width * 0.038,
        fontWeight: (fontWeight != null) ? fontWeight : FontWeight.bold,
      ),
    );
  }

  Widget RichTextFormat(
    String context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          _TextStyleWidget(
            context,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ],
      ),
    );
  }

  Widget RegisterBoxDecoration() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.051),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: width * 0.005),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(width * 0.04),
            topRight: Radius.circular(width * 0.04),
          ),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            InputFieldLabelAndField(
              "Full Name",
              "John Doe",
              nameTextController,
              "assets/images_register/User_icon.png",
            ),
            SizedBox(height: height * 0.015),
            InputFieldLabelAndField(
              "University Email",
              "you@university.edu",
              emailTextController,
              "assets/images_register/mail_icon.png",
            ),
            SizedBox(height: height * 0.015),
            InputFieldLabelAndField(
              "Password",
              "Enter your password",
              passTextController,
              "assets/images_register/Password_icon.png",
              isPassword: true,
              isHidden: hiddenText,
              onToggleVisibility: () {
                setState(() {
                  hiddenText = !hiddenText;
                });
              },
            ),
            SizedBox(height: height * 0.015),
            InputFieldLabelAndField(
              "Confirm Password",
              "Confirm your password",
              confirmPassTextController,
              "assets/images_register/Password_icon.png",
              isPassword: true,
              isHidden: confirmhiddenText,
              onToggleVisibility: () {
                setState(() {
                  confirmhiddenText = !confirmhiddenText;
                });
              },
            ),
            SizedBox(height: height * 0.02),
            PrivacyPolicyCheckBox(),
            SizedBox(height: height * 0.01),
            RegisterButton(),
            SizedBox(height: height * 0.035),
          ],
        ),
      ),
    );
  }

  Widget InputFieldLabelAndField(
    String label,
    String hintText,
    TextEditingController textController,
    String pathImage, {
    double? formFieldHeight,
    bool isPassword = false,
    bool? isHidden,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: RichTextFormat(
            label,
            color: Colors.black,
            fontSize: width * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: height * 0.005),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.035,
          ),
          child: SizedBox(
            height: (formFieldHeight != null) ? formFieldHeight : height * 0.05,
            child: TextFormField(
              controller: textController,
              obscureText: (isPassword) ? isHidden! : false,
              cursorHeight: (height * 0.045) * 0.6,
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.013,
                    vertical: width * 0.01,
                  ),
                  child: Image.asset(pathImage),
                ),
                suffixIcon: (isPassword)
                    ? (IconButton(
                        icon: Icon(
                          isHidden!
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black38,
                          size: width * 0.053,
                        ),
                        onPressed: onToggleVisibility,
                      ))
                    : null,
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: width * 0.038,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(114, 75, 230, 1),
                    width: width * 0.0041,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget PrivacyPolicyCheckBox() {
    return Row(
      children: [
        Checkbox(
          activeColor: const Color.fromRGBO(114, 75, 230, 1),
          checkColor: Colors.white,
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value!;
            });
          },
        ),
        RichTextFormat(
          "I agree to the",
          color: Colors.black38,
          fontSize: width * 0.03,
          fontWeight: FontWeight.w500,
        ),
        RichTextFormat(
          " Terms of Service",
          color: const Color.fromRGBO(114, 75, 230, 1),
          fontSize: width * 0.03,
          fontWeight: FontWeight.w500,
        ),
        RichTextFormat(
          " and",
          color: Colors.black38,
          fontSize: width * 0.03,
          fontWeight: FontWeight.w500,
        ),
        RichTextFormat(
          " Privacy Policy",
          color: const Color.fromRGBO(114, 75, 230, 1),
          fontSize: width * 0.03,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget RegisterButton() {
    return SizedBox(
      width: imageWidthAdjustment * 0.85,
      child: ElevatedButton(
        onPressed: register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(114, 75, 230, 0.7),
        ),
        child: RichTextFormat(
          "Sign Up",
          color: Colors.white,
          fontSize: width * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
