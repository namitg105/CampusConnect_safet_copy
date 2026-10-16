import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide Group;

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/usecases/group_usecases.dart';

part 'groups_event.dart';
part 'groups_state.dart';

/// Live list of every community (Community tab).
class GroupsBloc extends Bloc<GroupsEvent, GroupState> {
  final WatchGroups _watchGroups;
  StreamSubscription<Either<Failure, List<Group>>>? _subscription;

  GroupsBloc({required WatchGroups watchGroups})
      : _watchGroups = watchGroups,
        super(const GroupInitial()) {
    on<GroupsWatchStarted>(_onWatchStarted);
    on<_GroupsUpdated>((event, emit) => event.result.fold(
          (failure) => emit(GroupError(failure.message)),
          (groups) => emit(GroupLoaded(groups)),
        ));
  }

  /// Also used for pull-to-refresh: the previous listener is cancelled
  /// first, so there is only ever one Firestore subscription.
  Future<void> _onWatchStarted(
    GroupsWatchStarted event,
    Emitter<GroupState> emit,
  ) async {
    await _subscription?.cancel();
    emit(const GroupLoading());
    _subscription = _watchGroups(const NoParams())
        .listen((result) => add(_GroupsUpdated(result)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
