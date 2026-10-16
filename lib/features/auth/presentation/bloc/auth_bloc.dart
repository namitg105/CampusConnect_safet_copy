import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../home/presentation/pages/main_page.dart';
import '../../../private_chat/data/private-chat-services/user_friend_add.dart';
import '../../../private_chat/domain/repos/chat_controller.dart';
import '../../../private_chat/domain/repos/online_user_controller.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/user_login.dart';
import '../../domain/usecases/user_login_with_google.dart';
import '../../domain/usecases/user_logout.dart';
import '../../domain/usecases/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-wide session state. Provided once at the root in `main.dart`.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final UserLogin _userLogin;
  final UserSignUp _userSignUp;
  final UserLoginWithGoogle _userLoginWithGoogle;
  final UserLogout _userLogout;

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required UserLogin userLogin,
    required UserSignUp userSignUp,
    required UserLoginWithGoogle userLoginWithGoogle,
    required UserLogout userLogout,
  })  : _getCurrentUser = getCurrentUser,
        _userLogin = userLogin,
        _userSignUp = userSignUp,
        _userLoginWithGoogle = userLoginWithGoogle,
        _userLogout = userLogout,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserNameUpdated>(_onUserNameUpdated);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _emitResult(await _getCurrentUser(const NoParams()), emit);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );
    _emitResult(result, emit);
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _userSignUp(UserSignUpParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));
    _emitResult(result, emit);
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _emitResult(await _userLoginWithGoogle(const NoParams()), emit);
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _disposeSessionControllers();
    await _userLogout(const NoParams());
    emit(const Unauthenticated());
  }

  void _onUserNameUpdated(
    AuthUserNameUpdated event,
    Emitter<AuthState> emit,
  ) {
    final current = state;
    if (current is Authenticated) {
      emit(Authenticated(current.user.copyWith(name: event.name)));
    }
  }

  /// Shared by every handler that ends in "logged in or not".
  void _emitResult(Either<Failure, AppUser?> result, Emitter<AuthState> emit) {
    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(const Unauthenticated());
      },
      (user) =>
          emit(user != null ? Authenticated(user) : const Unauthenticated()),
    );
  }

  /// Removes per-user GetX controllers so the next account starts clean.
  /// Goes away once those features are migrated to Bloc.
  void _disposeSessionControllers() {
    if (Get.isRegistered<MainPageController>()) {
      Get.delete<MainPageController>(force: true);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>(force: true);
    }
    if (Get.isRegistered<UserController>()) {
      Get.delete<UserController>(force: true);
    }
    if (Get.isRegistered<UserOnlineController>()) {
      Get.delete<UserOnlineController>(force: true);
    }
  }
}
