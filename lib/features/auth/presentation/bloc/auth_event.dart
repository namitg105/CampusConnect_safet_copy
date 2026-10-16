part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App start: is there already a logged-in session on this device?
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

final class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// The profile screen changed the display name; keep the session in sync.
final class AuthUserNameUpdated extends AuthEvent {
  final String name;
  const AuthUserNameUpdated(this.name);

  @override
  List<Object?> get props => [name];
}
