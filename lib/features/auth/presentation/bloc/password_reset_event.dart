part of 'password_reset_bloc.dart';

sealed class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object?> get props => [];
}

final class PasswordResetRequested extends PasswordResetEvent {
  final String email;
  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}
