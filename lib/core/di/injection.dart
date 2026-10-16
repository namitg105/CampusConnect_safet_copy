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

import '../../features/home/presentation/bloc/main_nav_bloc.dart';
import '../../features/notification_badge/data/datasources/notification_badge_remote_data_source.dart';
import '../../features/notification_badge/data/repositories/notification_badge_repository_impl.dart';
import '../../features/notification_badge/domain/repositories/notification_badge_repository.dart';
import '../../features/notification_badge/domain/usecases/watch_unread_count.dart';
import '../../features/notification_badge/presentation/bloc/notification_badge_bloc.dart';

import '../../features/posts/data/datasources/post_remote_data_source.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';
import '../../features/posts/domain/repos/post_repo.dart';
import '../../features/posts/domain/usecases/create_post_usecase.dart';
import '../../features/posts/domain/usecases/get_feed_usecase.dart';
import '../../features/posts/domain/usecases/get_top_voted_usecase.dart';
import '../../features/posts/domain/usecases/get_post_by_id_usecase.dart';
import '../../features/posts/domain/usecases/delete_post_usecase.dart';
import '../../features/posts/domain/usecases/upvote_post_usecase.dart';
import '../../features/posts/domain/usecases/downvote_post_usecase.dart';
import '../../features/posts/domain/usecases/get_user_votes_usecase.dart';
import '../../features/posts/domain/usecases/update_poll_usecase.dart';
import '../../features/posts/domain/usecases/add_comment_usecase.dart';
import '../../features/posts/domain/usecases/get_comments_usecase.dart';
import '../../features/posts/domain/usecases/delete_comment_usecase.dart';
import '../../features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import '../../features/posts/domain/usecases/get_user_liked_comments_usecase.dart';
import '../../features/posts/presentation/bloc/feed/feed_bloc.dart';
import '../../features/posts/presentation/bloc/comments/comments_bloc.dart';
import '../../features/posts/presentation/bloc/create_post/create_post_bloc.dart';

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
  _initShell();
  _initPosts();

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

void _initShell() {
  sl
    ..registerLazySingleton<NotificationBadgeRemoteDataSource>(
      () => NotificationBadgeRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<NotificationBadgeRepository>(
      () => NotificationBadgeRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => WatchUnreadCount(sl()))
    ..registerFactory(() => NotificationBadgeBloc(watchUnreadCount: sl()))
    ..registerFactory(() => MainNavBloc());
}

void _initPosts() {
  sl
    ..registerLazySingleton<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<PostRepo>(() => PostRepositoryImpl(sl()))
    ..registerLazySingleton(() => CreatePostUseCase(repository: sl()))
    ..registerLazySingleton(() => GetFeedUseCase(repository: sl()))
    ..registerLazySingleton(() => GetTopVotedPostsUseCase(repository: sl()))
    ..registerLazySingleton(() => GetPostByIdUseCase(repository: sl()))
    ..registerLazySingleton(() => DeletePostUseCase(repository: sl()))
    ..registerLazySingleton(() => UpvotePostUseCase(repository: sl()))
    ..registerLazySingleton(() => DownvotePostUseCase(repository: sl()))
    ..registerLazySingleton(() => GetUserVotesUseCase(repository: sl()))
    ..registerLazySingleton(() => UpdatePollUseCase(repository: sl()))
    ..registerLazySingleton(() => AddCommentUseCase(repository: sl()))
    ..registerLazySingleton(() => GetCommentsUseCase(repository: sl()))
    ..registerLazySingleton(() => DeleteCommentUseCase(repository: sl()))
    ..registerLazySingleton(() => ToggleCommentLikeUseCase(repository: sl()))
    ..registerLazySingleton(
        () => GetUserLikedCommentsUseCase(repository: sl()))
    ..registerFactory(() => FeedBloc(
          getFeed: sl(),
          getTopVoted: sl(),
          getUserVotes: sl(),
          upvote: sl(),
          downvote: sl(),
          deletePost: sl(),
          updatePoll: sl(),
        ))
    ..registerFactory(() => CommentsBloc(
          getComments: sl(),
          getUserLikedComments: sl(),
          addComment: sl(),
          deleteComment: sl(),
          toggleCommentLike: sl(),
        ))
    ..registerFactory(() => CreatePostBloc(createPost: sl()));
}
