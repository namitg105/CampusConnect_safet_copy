/*
AuthCubit: State Management 
 */

import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repos/auth_repo.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/private_chat/data/private-chat-services/user_friend_add.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';
import 'package:noteswap/features/private_chat/domain/repos/online_user_controller.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  //get current user
  AppUser? get currentUser => _currentUser;

  //login with email pw
  Future<void> login(String email, String pw) async {
    try {
      print("AuthCubit login called");
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);
      if (user != null) {
        print("EMITTING AUTHENTICATED");
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        print("USER IS NULL");
        emit(Unauthenticated());
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //register with email pw
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //logout

  Future<void> logout() async {
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>(force: true);
    }
    if (Get.isRegistered<UserController>()) {
      Get.delete<UserController>(force: true);
    }
    if (Get.isRegistered<UserOnlineController>()) {
      Get.delete<UserOnlineController>(force: true);
    }

    await authRepo.logout();
    emit(Unauthenticated());
  }

  // Add this method inside your AuthCubit class

  Future<void> loginWithGoogle() async {
    try {
      emit(AuthLoading());

      final user = await authRepo.loginWithGoogle();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await authRepo.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
