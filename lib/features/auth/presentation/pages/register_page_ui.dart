import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/components/components.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/private_chat/presentation/common_widgets.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({super.key, this.togglePages});

  @override
  State<RegisterPage> createState() => RegisterPageUi();
}

class RegisterPageUi extends State<RegisterPage> {
  late double width, height;
  late Splash_Widget_Components _splashAppWidget;

  // Form controllers
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passTextController = TextEditingController();
  final confirmPassTextController = TextEditingController();
  bool hiddenText = true;
  bool confirmhiddenText = true;

  // Image controller
  final imagePath = "assets/images_register/register_girl_grouped_cropped.png";

  // Form checkbox
  bool isChecked = false;

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
    _splashAppWidget = Splash_Widget_Components(width: width, height: height);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Get.offAll(() => const MainPage());
        } else if (state is AuthError) {
          showErrorSnackbar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FF),
        appBar: _splashAppWidget.AppBarDesign(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Top Banner Area (Title, Subtitle & 3D Girl Illustration)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Create Your\n",
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Poppins',
                                      height: 1.15,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Account",
                                    style: TextStyle(
                                      color: Color(0xFF6139ED),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Join your university\ncommunity and\nstart connecting.",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                height: 1.3,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -5,
                        bottom: 0,
                        child: Image.asset(
                          imagePath,
                          width: width * 0.52,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Form Container Card
              RegisterBoxDecoration(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget RegisterBoxDecoration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputFieldLabelAndField(
              "Full Name",
              "Enter your full name",
              nameTextController,
              "assets/images_register/User_icon.png",
            ),
            const SizedBox(height: 14),
            InputFieldLabelAndField(
              "University Email",
              "you@university.edu",
              emailTextController,
              "assets/images_register/mail_icon.png",
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            PrivacyPolicyCheckBox(),
            const SizedBox(height: 18),
            RegisterButton(),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                "or Sign Up with",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  context.read<AuthCubit>().loginWithGoogle();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Image.asset(
                    "assets/google1.png",
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                GestureDetector(
                  onTap: _navigateToLogin,
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: Color(0xFF6139ED),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
    bool isPassword = false,
    bool? isHidden,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          obscureText: isPassword ? (isHidden ?? true) : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                pathImage,
                width: 22,
                height: 22,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (isHidden ?? true)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF6139ED),
                      size: 22,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFBDB2FA),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF6139ED),
                width: 2,
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
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            activeColor: const Color(0xFF6139ED),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            value: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 11, color: Colors.grey),
              children: [
                TextSpan(text: "I agree to the "),
                TextSpan(
                  text: "Terms of Service",
                  style: TextStyle(
                    color: Color(0xFF6139ED),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(
                    color: Color(0xFF6139ED),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget RegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6139ED),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
