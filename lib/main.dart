import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/Views/Onboarding/OnboardingFlowScreen.dart';
import 'package:noteswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noteswap/firebase_options.dart';

import 'features/home/presentation/bloc/main_nav_bloc.dart';
import 'features/notification_badge/presentation/bloc/notification_badge_bloc.dart';
import 'features/private_chat/presentation/bloc/friends/friends_bloc.dart';
import 'features/private_chat/presentation/common_widgets.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'core/di/injection.dart'; // DI injection init
import 'core/navigation/app_navigator.dart';

import 'features/home/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app') ||
        e.toString().contains('duplicate-app-name')) {
      debugPrint(
          'Firebase App already exists, ignoring duplicate-app exception.');
    } else {
      rethrow;
    }
  }

  // Initialize service locator
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        BlocProvider<MainNavBloc>(create: (_) => sl<MainNavBloc>()),
        BlocProvider<NotificationBadgeBloc>(
          create: (_) => sl<NotificationBadgeBloc>(),
        ),
        BlocProvider<FriendsBloc>(create: (_) => sl<FriendsBloc>()),
      ],
      child: _SessionListener(
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) => MaterialApp(
            navigatorKey: rootNavigatorKey,
            scaffoldMessengerKey: rootMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode:
                themeState.isLightMode ? ThemeMode.light : ThemeMode.dark,
            scrollBehavior: MyCustomScrollBehavior(),
            home: const AuthWrapper(),
          ),
        ),
      ),
    );
  }
}

/// Reacts once whenever the logged-in user changes (login, logout, switch).
/// Lives above MaterialApp so it keeps working when screens are replaced.
class _SessionListener extends StatelessWidget {
  final Widget child;
  const _SessionListener({required this.child});

  static String? _uidOf(AuthState state) =>
      state is Authenticated ? state.user.uid : null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => _uidOf(previous) != _uidOf(current),
      listener: (context, state) {
        final badge = context.read<NotificationBadgeBloc>();
        final friends = context.read<FriendsBloc>();
        if (state is Authenticated) {
          badge.add(NotificationBadgeStarted(
            uid: state.user.uid,
            email: state.user.email,
          ));
          friends.add(FriendsWatchStarted(state.user.uid));
        } else {
          badge.add(const NotificationBadgeStopped());
          friends.add(const FriendsWatchStopped());
          context.read<MainNavBloc>().add(const MainNavReset());
        }
      },
      child: BlocListener<FriendsBloc, FriendsState>(
        // Friend actions (requests, block...) report here, whatever screen
        // the user is on.
        listenWhen: (p, c) => p.outcomeId != c.outcomeId,
        listener: (context, state) {
          final outcome = state.outcome!;
          switch (outcome.kind) {
            case FriendsOutcomeKind.success:
              showSuccessSnackbar(outcome.message);
            case FriendsOutcomeKind.info:
              showInfoSnackbar(outcome.message);
            case FriendsOutcomeKind.error:
              showErrorSnackbar(outcome.message);
          }
        },
        child: child,
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

/// A wrapper view that dynamically directs the user based on their login status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${authState.message}")),
          );
        }
      },
      builder: (context, authState) {
        print("Current UI Auth State: $authState");
        if (authState is Authenticated) {
          return const MainPage(); // Land on MainPage (includes bottom navigation)
        } else if (authState is Unauthenticated) {
          return const OnboardingFlowScreen(initialPage: 0);
        }

        // Handles loading or initial authentication state resolution
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6139ED),
            ),
          ),
        );
      },
    );
  }
}
