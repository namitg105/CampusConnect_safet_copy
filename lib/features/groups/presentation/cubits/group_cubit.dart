import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repos/group_repo.dart';
import 'group_states.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepo repo;

  StreamSubscription? _sub;

  GroupCubit(this.repo) : super(GroupInitial());

  Future<void> joinGroup(
    String groupId,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await repo.joinGroup(
      groupId,
      uid,
    );
  }

  void loadGroups(
    String collegeId,
  ) {
    emit(GroupLoading());

    _sub?.cancel();

    _sub = repo.getGroups(collegeId).listen((groups) {
      emit(GroupLoaded(groups));
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
