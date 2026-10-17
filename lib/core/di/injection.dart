import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repos/chat_repo.dart';
import '../../features/chat/domain/usecases/chat_usecases.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

import '../../features/community/data/datasources/group_remote_data_source.dart';
import '../../features/community/data/repositories/group_repository_impl.dart';
import '../../features/community/domain/repos/group_repo.dart';
import '../../features/community/domain/usecases/group_usecases.dart';
import '../../features/community/presentation/bloc/create_group/create_group_bloc.dart';
import '../../features/community/presentation/bloc/groups/groups_bloc.dart';
import '../../features/community/presentation/bloc/membership/membership_bloc.dart';

import '../../features/group_chat/data/firebase_group_chat_repo.dart';
import '../../features/group_chat/domain/repo/group_chat_repo.dart';
import '../../features/security/aes_service.dart';
import '../../features/notes/data/datasources/note_storage_service.dart';
import '../../features/notes/data/datasources/notes_backend_switch.dart';
import '../../features/notes/data/datasources/notes_data_source.dart';
import '../../features/notes/data/datasources/notes_firestore_data_source.dart';
import '../../features/notes/data/datasources/notes_hardcoded_data_source.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/notes_usecases.dart';
import '../../features/notes/presentation/bloc/notes_bloc.dart';
import '../../features/notes/presentation/bloc/note_detail_bloc.dart';
import '../../features/notes/presentation/bloc/note_search_bloc.dart';
import '../../features/private_chat/data/datasources/friends_remote_data_source.dart';
import '../../features/private_chat/data/datasources/private_chat_remote_data_source.dart';
import '../../features/private_chat/data/repositories/friends_repository_impl.dart';
import '../../features/private_chat/data/repositories/private_chat_repository_impl.dart';
import '../../features/private_chat/domain/repositories/friends_repository.dart';
import '../../features/private_chat/domain/repositories/private_chat_repository.dart';
import '../../features/private_chat/domain/usecases/friends_usecases.dart';
import '../../features/private_chat/domain/usecases/private_chat_usecases.dart';
import '../../features/private_chat/presentation/bloc/friends/friends_bloc.dart';
import '../../features/private_chat/presentation/bloc/chat_rooms/chat_rooms_bloc.dart';
import '../../features/private_chat/presentation/bloc/conversation/conversation_bloc.dart';
import '../../features/private_chat/presentation/bloc/chat_details/chat_details_bloc.dart';

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

  sl.registerLazySingleton<AESService>(() => AESService());
  _initCommunity();
  _initChat();
  _initPrivateChat();
  _initNotes();

  // Not used by any screen yet (group_chat feature).
  sl.registerLazySingleton<GroupChatRepo>(
    () => FirebaseGroupChatRepo(),
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

void _initCommunity() {
  sl
    ..registerLazySingleton<GroupRemoteDataSource>(
      () => GroupRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<GroupRepo>(() => GroupRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchGroups(sl()))
    ..registerLazySingleton(() => WatchJoinedGroupIds(sl()))
    ..registerLazySingleton(() => WatchPendingJoinRequests(sl()))
    ..registerLazySingleton(() => CreateGroup(sl()))
    ..registerLazySingleton(() => JoinGroup(sl()))
    ..registerLazySingleton(() => LeaveGroup(sl()))
    ..registerLazySingleton(() => RequestToJoinGroup(sl()))
    ..registerLazySingleton(() => CancelJoinRequest(sl()))
    ..registerLazySingleton(() => GetGroupAdminId(sl()))
    ..registerFactory(() => GroupsBloc(watchGroups: sl()))
    ..registerFactory(() => MembershipBloc(
          watchJoinedGroupIds: sl(),
          watchPendingJoinRequests: sl(),
          joinGroup: sl(),
          leaveGroup: sl(),
          requestToJoinGroup: sl(),
          cancelJoinRequest: sl(),
          getGroupAdminId: sl(),
        ))
    ..registerFactory(() => CreateGroupBloc(createGroup: sl()));
}

void _initChat() {
  sl
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        firestore: sl(),
        auth: sl(),
        storage: FirebaseStorage.instance,
        aes: sl(),
      ),
    )
    ..registerLazySingleton<ChatRepo>(() => ChatRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchMessages(sl()))
    ..registerLazySingleton(() => SendTextMessage(sl()))
    ..registerLazySingleton(() => SendMediaMessage(sl()))
    ..registerLazySingleton(() => DeleteMessage(sl()))
    ..registerLazySingleton(() => PinMessage(sl()))
    ..registerLazySingleton(() => UnpinMessage(sl()))
    ..registerFactory(() => ChatBloc(
          watchMessages: sl(),
          sendTextMessage: sl(),
          sendMediaMessage: sl(),
          deleteMessage: sl(),
          pinMessage: sl(),
          unpinMessage: sl(),
        ));
}

void _initPrivateChat() {
  sl
    // Data
    ..registerLazySingleton<FriendsRemoteDataSource>(
      () => FriendsRemoteDataSourceImpl(firestore: sl(), auth: sl()),
    )
    ..registerLazySingleton<PrivateChatRemoteDataSource>(
      () => PrivateChatRemoteDataSourceImpl(
        firestore: sl(),
        storage: FirebaseStorage.instance,
      ),
    )
    ..registerLazySingleton<FriendsRepository>(() => FriendsRepositoryImpl(sl()))
    ..registerLazySingleton<PrivateChatRepository>(
        () => PrivateChatRepositoryImpl(sl()))
    // Friends use cases
    ..registerLazySingleton(() => WatchFriends(sl()))
    ..registerLazySingleton(() => WatchOnlineStatuses(sl()))
    ..registerLazySingleton(() => WatchBlockedUids(sl()))
    ..registerLazySingleton(() => WatchIncomingRequests(sl()))
    ..registerLazySingleton(() => WatchSentRequestUids(sl()))
    ..registerLazySingleton(() => WatchIgnoredRequests(sl()))
    ..registerLazySingleton(() => WatchDirectory(sl()))
    ..registerLazySingleton(() => SendFriendRequest(sl()))
    ..registerLazySingleton(() => AcceptFriendRequest(sl()))
    ..registerLazySingleton(() => DeclineFriendRequest(sl()))
    ..registerLazySingleton(() => AcceptIgnoredRequest(sl()))
    ..registerLazySingleton(() => BlockUser(sl()))
    ..registerLazySingleton(() => UnblockUser(friends: sl(), chat: sl()))
    // Chat use cases
    ..registerLazySingleton(() => WatchChatRooms(sl()))
    ..registerLazySingleton(() => GetOrCreateChatRoom(sl()))
    ..registerLazySingleton(() => WatchRoomMessages(sl()))
    ..registerLazySingleton(() => WatchPinnedMessage(sl()))
    ..registerLazySingleton(() => WatchUserOnline(sl()))
    ..registerLazySingleton(() => MarkRoomAsRead(sl()))
    ..registerLazySingleton(() => SendPrivateMessage(sl()))
    ..registerLazySingleton(() => ToggleReaction(sl()))
    ..registerLazySingleton(() => DeletePrivateMessage(sl()))
    ..registerLazySingleton(() => PinPrivateMessage(sl()))
    ..registerLazySingleton(() => UnpinPrivateMessage(sl()))
    ..registerLazySingleton(() => GetRoomDetails(sl()))
    ..registerLazySingleton(() => GetSharedImages(sl()))
    ..registerLazySingleton(() => GetSharedDocuments(sl()))
    ..registerLazySingleton(() => GetPhoneNumber(sl()))
    // Blocs
    ..registerFactory(() => FriendsBloc(
          watchFriends: sl(),
          watchOnlineStatuses: sl(),
          watchBlockedUids: sl(),
          watchIncomingRequests: sl(),
          watchSentRequestUids: sl(),
          watchIgnoredRequests: sl(),
          watchDirectory: sl(),
          sendFriendRequest: sl(),
          acceptFriendRequest: sl(),
          declineFriendRequest: sl(),
          acceptIgnoredRequest: sl(),
          blockUser: sl(),
          unblockUser: sl(),
        ))
    ..registerFactory(() => ChatRoomsBloc(
          watchChatRooms: sl(),
          getOrCreateChatRoom: sl(),
        ))
    ..registerFactory(() => ConversationBloc(
          watchRoomMessages: sl(),
          watchPinnedMessage: sl(),
          watchUserOnline: sl(),
          markRoomAsRead: sl(),
          sendPrivateMessage: sl(),
          toggleReaction: sl(),
          deletePrivateMessage: sl(),
          pinPrivateMessage: sl(),
          unpinPrivateMessage: sl(),
          getPhoneNumber: sl(),
        ))
    ..registerFactory(() => ChatDetailsBloc(
          getRoomDetails: sl(),
          getSharedImages: sl(),
          getSharedDocuments: sl(),
        ));
}

void _initNotes() {
  sl
    ..registerLazySingleton<NotesDataSource>(
      // `useHarcoded` switches the whole Notes module to offline demo data.
      () => useHarcoded
          ? NotesHardcodedDataSource()
          : NotesFirestoreDataSource(
              firestore: sl(),
              auth: sl(),
              storage: NoteStorageService(FirebaseStorage.instance),
            ),
    )
    ..registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetHomeNotes(sl()))
    ..registerLazySingleton(() => SearchNotes(sl()))
    ..registerLazySingleton(() => GetNoteDetail(sl()))
    ..registerLazySingleton(() => GetMyNotes(sl()))
    ..registerLazySingleton(() => UploadNote(sl()))
    ..registerLazySingleton(() => DeleteNote(sl()))
    ..registerLazySingleton(() => PurchaseNote(sl()))
    ..registerLazySingleton(() => RecordDownload(sl()))
    ..registerFactory(() => NotesBloc(
          getHomeNotes: sl(),
          getMyNotes: sl(),
          uploadNote: sl(),
          deleteNote: sl(),
        ))
    ..registerFactory(() => NoteDetailBloc(
          getNoteDetail: sl(),
          purchaseNote: sl(),
          recordDownload: sl(),
        ))
    ..registerFactory(() => NoteSearchBloc(searchNotes: sl()));
}
