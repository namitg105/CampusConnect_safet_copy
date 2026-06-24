import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../features/chat/data/firebase_chat_repo.dart';
import '../../features/chat/domain/repos/chat_repo.dart';
import '../../features/chat/presentation/cubits/chat_cubit.dart';

import '../../features/groups/data/firebase_group_repo.dart';
import '../../features/groups/domain/repos/group_repo.dart';
import '../../features/groups/presentation/cubits/group_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  sl.registerLazySingleton<GroupRepo>(
    () => FirebaseGroupRepo(sl()),
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
