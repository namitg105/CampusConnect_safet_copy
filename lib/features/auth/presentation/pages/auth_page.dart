/*
Auth Page- This page determines whether to show login page or register page 
 */
import 'package:flutter/widgets.dart';
import 'package:noteswap/features/auth/presentation/pages/LoginScreen.dart';
import 'package:noteswap/features/auth/presentation/pages/register_page_ui.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
//initially show login page 
bool showLoginPage=true;


//toggle between pages 
void togglePages(){
setState(() {
  showLoginPage=!showLoginPage;
});  
}

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return   Loginscreen(togglePages:togglePages,);

    }else{
      return   RegisterPage(togglePages: togglePages,);
    }

  }
}