import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/home/presentation/pages/home_page.dart';

class Loginscreen extends StatefulWidget {
  final void Function()? togglePages;

  const Loginscreen({super.key, required this.togglePages});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  //text controllers

  final emailController = TextEditingController();
  final pwController = TextEditingController();

//forgot password button pressed
  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController =
        TextEditingController(text: emailController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Reset Password",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your university email to receive a password reset link.",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  hintText: "you@university.edu",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFFBDB2FA), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF6139ED), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6139ED)),
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) return;

                // Show loading circle
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  // Call the Cubit method instead of Firebase directly
                  await context.read<AuthCubit>().sendPasswordResetEmail(email);

                  if (context.mounted) {
                    Navigator.pop(context); // pop loading
                    Navigator.pop(context); // pop dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Reset link sent! Check your email."),
                          backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // pop loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Send Link",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

//login button pressed
  void login() {
    final String email = emailController.text;
    final String pw = pwController.text;

    //authcubit
    final authCubit = context.read<AuthCubit>();

    //ensure email and pw fields are not empty
    if (email.isNotEmpty && pw.isNotEmpty) {
      //login
      authCubit.login(email, pw);
    }

    //display error if some fields are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // This clears the navigation stack and safely lands them on HomePage
            Get.offAll(() => const HomePage());
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 20,
                left: 22,
                width: 200,
                child: Image.asset("assets/Heading.png"),
              ),
              Positioned(
                top: 100,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      "Back!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6139ED),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Login in to continue your\ncampus journey.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  top: 0,
                  right: 10,
                  bottom: 250,
                  width: 340,
                  child: Image.asset("assets/student_Image1.png")),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: MediaQuery.of(context).size.height * 0.58,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "University Email",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "you@university.edu",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/mail.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 5),
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
                          const SizedBox(height: 16),
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: pwController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/lock.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  // Toggle password visibility
                                },
                                icon: Image.asset(
                                  'assets/Eye_icon.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 5),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: const Text(
                                "Forget Password?",
                                style: TextStyle(
                                    color: Color(0xFF6139ED),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: GestureDetector(
                              onTap: login,
                              child: Image.asset(
                                'assets/Login_button.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Center(
                            child: Text(
                              "or continue with",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                // Navigate or Google Sign-In logic
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    context.read<AuthCubit>().loginWithGoogle();
                                  },
                                  icon: Image.asset(
                                    "assets/google1.png",
                                    width: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: widget.togglePages,
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Color(0xFF6139ED),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
