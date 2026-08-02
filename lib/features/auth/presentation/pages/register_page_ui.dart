import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/components/components.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';
import 'package:noteswap/features/private_chat/presentation/common_widgets.dart';

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

  //-------------------form controllers-----------------------//
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passTextController = TextEditingController();
  final confirmPassTextController = TextEditingController();

  bool hiddenText = true;
  bool confirmhiddenText = true;

  //-------------------image controller----------------------//
  final imagePath = "assets/images_register/register_girl_grouped_cropped.png";

  //-------------------form state-----------------------//
  bool isChecked = false;

  //register button pressed
  void register() {
    final email = emailTextController.text.trim();
    final name = nameTextController.text.trim();
    final pw = passTextController.text.trim();
    final confirmPw = confirmPassTextController.text.trim();

    if (email.isEmpty || pw.isEmpty || name.isEmpty || confirmPw.isEmpty) {
      showErrorSnackbar("Please complete all fields");
      return;
    }

    if (pw != confirmPw) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Password Mismatch",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            "Passwords do not match",
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

    if (!isChecked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

    // Call AuthCubit to register user via Firebase
    final authCubit = context.read<AuthCubit>();
    authCubit.register(name, email, pw);
  }

  void _navigateToLogin() {
    if (widget.togglePages != null) {
      widget.togglePages!();
    } else {
      Get.offAll(() => const AuthPage());
    }
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
    imageWidthAdjustment = width / 1.1;
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
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
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
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget RichTextFormat(
    String content, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          _TextStyleWidget(
            content,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ],
      ),
    );
  }

  Widget RegisterBoxDecoration() {
    return Container(
      width: imageWidthAdjustment,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.025),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10.0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: height * 0.025),
          textFormLayout(
            isPassword: false,
            labelText: "Full Name",
            pathImage: "assets/images_register/User_icon.png",
            textController: nameTextController,
            hintText: "Enter your full name",
          ),
          SizedBox(height: height * 0.025),
          textFormLayout(
            isPassword: false,
            labelText: "University Email",
            pathImage: "assets/images_register/mail_icon.png",
            textController: emailTextController,
            hintText: "you@university.edu",
          ),
          SizedBox(height: height * 0.025),
          textFormLayout(
            isPassword: true,
            labelText: "Password",
            pathImage: "assets/images_register/Password_icon.png",
            textController: passTextController,
            hintText: "Enter your password",
            isHidden: hiddenText,
            onToggleVisibility: () {
              setState(() {
                hiddenText = !hiddenText;
              });
            },
          ),
          SizedBox(height: height * 0.025),
          textFormLayout(
            isPassword: true,
            labelText: "Confirm Password",
            pathImage: "assets/images_register/Password_icon.png",
            textController: confirmPassTextController,
            hintText: "Confirm your password",
            isHidden: confirmhiddenText,
            onToggleVisibility: () {
              setState(() {
                confirmhiddenText = !confirmhiddenText;
              });
            },
          ),
          SizedBox(height: height * 0.005),
          Container(
            margin: EdgeInsets.only(left: width * 0.025),
            child: PrivacyPolicyCheckBox(),
          ),
          RegisterButton(),
          SizedBox(height: width * 0.025),
          RichTextFormat(
            "or sign up with",
            fontSize: width * 0.0325,
            color: Colors.black38,
          ),
          Container(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () {
                context.read<AuthCubit>().loginWithGoogle();
              },
              icon: Image.asset("assets/images_register/Google_icon.png"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichTextFormat(
                "Already have an account?",
                fontSize: width * 0.0325,
                color: Colors.black38,
              ),
              TextButton(
                onPressed: _navigateToLogin,
                child: RichTextFormat(
                  " Log in",
                  fontSize: width * 0.0325,
                  color: const Color.fromRGBO(114, 75, 230, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textFormLayout({
    required bool isPassword,
    required String labelText,
    required String pathImage,
    double? sizedBoxHeight,
    double? formFieldHeight,
    TextEditingController? textController,
    String? hintText,
    bool? isHidden,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.035),
          child: RichTextFormat(
            labelText,
            color: Colors.black,
            fontSize: width * 0.0325,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: (sizedBoxHeight != null) ? sizedBoxHeight : height * 0.00725,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.035,
          ),
          child: SizedBox(
            height: (formFieldHeight != null) ? formFieldHeight : height * 0.05,
            child: TextFormField(
              controller: textController,
              obscureText: (isPassword) ? (isHidden ?? true) : false,
              cursorHeight: (height * 0.045) * 0.6,
              decoration: InputDecoration(
                isDense: true,
                hintText: (hintText != null) ? hintText : "Enter",
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.013,
                    vertical: width * 0.01,
                  ),
                  child: Image.asset(
                    pathImage,
                  ),
                ),
                suffixIcon: (isPassword)
                    ? (IconButton(
                        icon: Icon(
                          (isHidden ?? true)
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
              isChecked = value ?? false;
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
