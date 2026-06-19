import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/auth/presentation/components/components.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';

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
  late bool hiddenText = false;
  late bool confirmhiddenText = false;

  //-------------------image controller----------------------//
  final imagePath = "assets/images_register/register_girl_grouped_cropped.png";
  late AssetImage imageProvider;
  late double displayedHeight = 0.0;
  //-------------------form controller-----------------------//
  late bool isChecked = false;

//register button pressed
  void register() {
//prepare info
    final email = emailTextController.text;
    final name = nameTextController.text;
    final pw = passTextController.text;
    final confirmPw = confirmPassTextController.text;

//auth cubit
    final authCubit = context.read<AuthCubit>();

//ensure fields aren't empty
    if (email.isNotEmpty && pw.isNotEmpty && name.isNotEmpty) {
      //register user
      authCubit.register(name, email, pw);
    }

//fields are empty-> display error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all fields")));
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
    imageWidthAdjustment = width / 1.1; //width / 1.2
    _splashAppWidget = Splash_Widget_Components(width: width, height: height);

    return Scaffold(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black38, //const Color.fromARGB(143, 0, 0, 0)
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
            labelText: "Univeristy Email",
            pathImage: "assets/images_register/mail_icon.png",
            textController: emailTextController,
            hintText: "you@univeristy.edu",
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
                onPressed: widget.togglePages,
                child: RichTextFormat(
                  "Log in",
                  fontSize: width * 0.0325,
                  color: Color.fromRGBO(114, 75, 230, 1),
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
        ), //height * 0.00725
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.035,
            //vertical: height * 0.01,
          ),
          child: SizedBox(
            height: (formFieldHeight != null) ? formFieldHeight : height * 0.05,
            child: TextFormField(
              controller: textController,
              obscureText: (isPassword) ? isHidden! : false,
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
                  ), //"assets/images_register/mail_icon.png"
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
                    color: Color.fromRGBO(114, 75, 230, 1),
                    width: width * 0.0041,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  borderSide: BorderSide(color: Colors.black),
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
          activeColor: Color.fromRGBO(114, 75, 230, 1),
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
          color: Color.fromRGBO(114, 75, 230, 1),
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
          color: Color.fromRGBO(114, 75, 230, 1),
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
          backgroundColor: Color.fromRGBO(114, 75, 230, 0.7),
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

//Padding(padding: EdgeInsets.all(width * 0.01), child: Image.asset(""),)
//Color.fromRGBO(114, 75, 230, 1)
//width * 0.065
//fontweight.bold
// Image.asset(
//   "assets/images_register/login_girl_image.png",
//   width: width / 1.2,
// ),
// ImageAssetProvider(
//   "assets/images_register/login_girl_image_cropped.png",
//   top: height * 0.05,
//   right: 0,
//   width: width / 1.2,
// ),
/*Row(
  children: [
    Stack(
      children: [
        ImageAssetProvider(
          "assets/images_register/login_girl_image_cropped.png",
          false,
          width: width / 1.2,
          //top: height * 0.09,
          //right: 0.0, //width * 0.055
    
        RegisterText(),
      ],
    ),
  ],
),*/
/*SizedBox(
  width: width,
  height: ImageAssetSizeProvider(
    path: imagePath,
    displayedWidth: width / 1.2,
  ),
  child: Stack(
    children: [
      ImageAssetProvider(
        imagePath,
        false,
        width: width / 1.2,
        top: height * 0.09,
        right: 0.0, //width * 0.055
      ),
      RegisterText(),
    ],
  ),
),*/
/*RegisterBoxDecoration(),*/
/*
  Widget ImageAssetProvider(
    String path,
    bool alignmentFix, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    double? width,
    Alignment? alignDirection,
  }) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child:
          (alignmentFix && alignDirection != null)
              ? Align(
                alignment: alignDirection,
                child: Image.asset(path, width: width),
              )
              : Image.asset(path, width: width),
    );
  }
  */
/*

  double ImageAssetSizeProvider({
    required String path,
    required double displayedWidth,
  }) {
    imageProvider = AssetImage(path);

    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, _) {
            final originalWidth = info.image.width;
            final originalHeight = info.image.height;
            displayedHeight = (displayedWidth * originalHeight) / originalWidth;
          }),
        );
    return displayedHeight + (height * 0.08);
  }
*/
/*  Widget RegisterText() {
    return Container(
      margin: EdgeInsets.only(top: height * 0.03, left: height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichTextFormat(
            "Create Your",
            color: Colors.black,
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
          ),
          RichTextFormat(
            "Account",
            color: Color.fromRGBO(114, 75, 230, 1),
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: height * 0.03),
          SizedBox(
            width: width / 2.5,
            child: RichTextFormat(
              "join your university community and start connecting",
              color: Color.fromRGBO(0, 0, 0, 1),
              fontSize: width * 0.035,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  } 
*/
