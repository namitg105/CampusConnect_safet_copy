import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/send_password_reset_email.dart';
import '../../features/auth/domain/usecases/user_login.dart';
import '../../features/auth/domain/usecases/user_login_with_google.dart';
import '../../features/auth/domain/usecases/user_logout.dart';
import '../../features/auth/domain/usecases/user_sign_up.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/password_reset_bloc.dart';

import '../../features/chat/data/firebase_chat_repo.dart';
import '../../features/chat/domain/repos/chat_repo.dart';
import '../../features/chat/presentation/cubits/chat_cubit.dart';

import '../../features/community/data/firebase_group_repo.dart';
import '../../features/community/domain/repos/group_repo.dart';
import '../../features/community/presentation/cubits/group_cubit.dart'
    show GroupCubit;

import '../../features/group_chat/data/firebase_group_chat_repo.dart';
import '../../features/group_chat/domain/repo/group_chat_repo.dart';
import '../../features/security/aes_service.dart';

import '../../features/theme/data/datasources/theme_local_data_source.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/usecases/get_saved_theme.dart';
import '../../features/theme/domain/usecases/save_theme.dart';
import '../../features/theme/presentation/bloc/theme_bloc.dart';

final sl = GetIt.instance;

const _settingsBoxName = 'settings';

/// Registration order: external services -> data sources -> repositories
/// -> use cases -> blocs.
Future<void> init() async {
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Local key-value storage (replaces GetStorage).
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox(_settingsBoxName);

  _initAuth();
  _initTheme(settingsBox);

  sl.registerLazySingleton<AESService>(
    () => AESService(),
  );

  // Repositories
  sl.registerLazySingleton<GroupRepo>(
    () => FirebaseGroupRepo(sl()),
  );

  sl.registerLazySingleton<GroupChatRepo>(
    () => FirebaseGroupChatRepo(),
  );

  sl.registerLazySingleton<ChatRepo>(
    () => FirebaseChatRepo(sl()),
  );

  sl.registerLazySingleton<FirebaseGroupRepo>(
    () => FirebaseGroupRepo(
      FirebaseFirestore.instance,
    ),
  );

  sl.registerFactory<GroupCubit>(
    () => GroupCubit(sl()),
  );

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(sl()),
  );
}

void _initAuth() {
  sl
    // Data sources
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: sl(),
        firestore: sl(),
        googleSignIn: sl(),
      ),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    // Use cases
    ..registerLazySingleton(() => GetCurrentUser(sl()))
    ..registerLazySingleton(() => UserLogin(sl()))
    ..registerLazySingleton(() => UserSignUp(sl()))
    ..registerLazySingleton(() => UserLoginWithGoogle(sl()))
    ..registerLazySingleton(() => UserLogout(sl()))
    ..registerLazySingleton(() => SendPasswordResetEmail(sl()))
    // Blocs
    ..registerFactory(
      () => AuthBloc(
        getCurrentUser: sl(),
        userLogin: sl(),
        userSignUp: sl(),
        userLoginWithGoogle: sl(),
        userLogout: sl(),
      ),
    )
    ..registerFactory(
      () => PasswordResetBloc(sendPasswordResetEmail: sl()),
    );
}

void _initTheme(Box settingsBox) {
  sl
    ..registerLazySingleton<ThemeLocalDataSource>(
      () => ThemeLocalDataSourceImpl(settingsBox),
    )
    ..registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetSavedTheme(sl()))
    ..registerLazySingleton(() => SaveTheme(sl()))
    ..registerFactory(() => ThemeBloc(getSavedTheme: sl(), saveTheme: sl()));
}
