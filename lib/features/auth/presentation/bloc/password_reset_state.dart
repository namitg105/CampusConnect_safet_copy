part of 'password_reset_bloc.dart';

sealed class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

final class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
}

final class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
}

final class PasswordResetSent extends PasswordResetState {
  const PasswordResetSent();
}

final class PasswordResetFailure extends PasswordResetState {
  final String message;
  const PasswordResetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
