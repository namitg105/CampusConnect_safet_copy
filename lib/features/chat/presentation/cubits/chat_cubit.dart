import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repos/chat_repo.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo repo;

  StreamSubscription? _sub;

  ChatCubit(this.repo) : super(ChatInitial());

  void loadMessages(
    String groupId,
  ) {
    emit(ChatLoading());

    _sub?.cancel();

    _sub = repo.getMessages(groupId).listen(
      (messages) {
        emit(
          ChatLoaded(messages),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
