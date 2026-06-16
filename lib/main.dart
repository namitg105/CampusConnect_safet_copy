import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/data/firebase_auth_repo.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/LoginScreen.dart';
import 'package:noteswap/Views/OnboardingScreen3.dart';
import 'package:noteswap/features/auth/presentation/pages/sign_up_page.dart';
import 'package:noteswap/features/home/presentation/pages/home_page.dart';
import 'package:noteswap/firebase_options.dart';
import 'ViewModels/DarkModeViewModels.dart';
import 'Views/Onboarding/OnboardingScreen.dart';
import 'Views/SplashScreen.dart';

void main()async  {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(LightModeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController darkModeController = Get.put(LightModeController());

    return MultiBlocProvider(providers: 
    [
      BlocProvider<AuthCubit>(create: (context)=>AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()
      )
      ],
    
    
     child:BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);
            if (authState is Unauthenticated) {
              // -Unauthenticated->auth page(login/register)
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Loginscreen(),
              );
            }
            if(authState is AuthLoading){
              return MaterialApp(
                home: const Scaffold(body: 
                Center(child: CircularProgressIndicator())),
              );
            }
            if (authState is Authenticated) {
              //-Authenticated->home page
              return    Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: darkModeController.isLightMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/homeScreen',
      getPages: [
        GetPage(name: '/homeScreen', page: () => HomePage()),
        GetPage(name: '/onboardingScreen', page: () => OnboardingScreen()),
      ],
    )
    );
            }
            //loading..
            else {
              //show loading indicator while checking auth state
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
          },

          //listen for any errors
          listener: (context, authState) {
            if (authState is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${authState.message}")));
            }
          },
        ),
     
     
     
     
     
     
     
     
     
     
     
    
    );
  }
}

