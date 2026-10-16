import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_password_reset_email.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

/// Drives the "Forgot password?" dialog. Kept separate from `AuthBloc` so a
/// reset request never replaces the app-wide session state (SRP).
class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final SendPasswordResetEmail _sendPasswordResetEmail;

  PasswordResetBloc({required SendPasswordResetEmail sendPasswordResetEmail})
      : _sendPasswordResetEmail = sendPasswordResetEmail,
        super(const PasswordResetInitial()) {
    on<PasswordResetRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PasswordResetRequested event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(const PasswordResetLoading());
    final result = await _sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure.message)),
      (_) => emit(const PasswordResetSent()),
    );
  }
}
