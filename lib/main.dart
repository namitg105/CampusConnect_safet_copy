import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/auth/data/firebase_auth_repo.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/home/presentation/pages/home_page.dart';
import 'package:noteswap/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
 const  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Provide the Repository at the top level
    return RepositoryProvider(
        create: (context) => FirebaseAuthRepo(),

        // 2. Use MultiBlocProvider for all your app-wide Cubits
        child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>(
                create: (context) => AuthCubit(
                  authRepo: context.read<FirebaseAuthRepo>(),
                )..checkAuth(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,

              // 4. BlocConsumer handles the routing
              home: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, authState) {
                  if (authState is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${authState.message}")),
                    );
                  }
                },
                builder: (context, authState) {
                  if (authState is Authenticated) {
                    return const HomePage();
                  } else if (authState is Unauthenticated) {
                    return const AuthPage();
                  }

                  // Covers AuthLoading and the initial state
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
            ),
          )
        )
      );
  }
}
