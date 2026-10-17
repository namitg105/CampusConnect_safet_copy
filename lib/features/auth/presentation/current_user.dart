import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/app_user.dart';
import 'bloc/auth_bloc.dart';

/// Reads the logged-in user from [AuthBloc] (instead of `FirebaseAuth`
/// directly, so screens stay out of the data layer).
extension CurrentUserContext on BuildContext {
  AppUser? get currentUser {
    final state = read<AuthBloc>().state;
    return state is Authenticated ? state.user : null;
  }

  /// '' when nobody is logged in.
  String get currentUid => currentUser?.uid ?? '';
}
