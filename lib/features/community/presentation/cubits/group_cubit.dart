import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repos/group_repo.dart';
import 'group_states.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepo repo;

  StreamSubscription? _sub;

  GroupCubit(this.repo) : super(GroupInitial());

  /// Load all communities
  void loadGroups() {
    emit(GroupLoading());

    _sub?.cancel();

    _sub = repo.getGroups().listen(
      (groups) {
        emit(GroupLoaded(groups));
      },
      onError: (e) {
        emit(GroupError(e.toString()));
      },
    );
  }

  /// Load only joined communities
  void loadJoinedGroups() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(GroupLoaded([]));
      return;
    }

    emit(GroupLoading());

    _sub?.cancel();

    _sub = repo.getJoinedGroups(user.uid).listen(
      (groups) {
        emit(GroupLoaded(groups));
      },
      onError: (e) {
        emit(GroupError(e.toString()));
      },
    );
  }

  Future<void> joinGroup(String groupId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await repo.joinGroup(groupId, user.uid);
  }

  Future<void> leaveGroup(String groupId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await repo.leaveGroup(groupId, user.uid);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
