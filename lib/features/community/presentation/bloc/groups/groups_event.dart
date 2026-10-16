part of 'groups_bloc.dart';

sealed class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

/// Start (or restart, for pull-to-refresh) listening to all communities.
final class GroupsWatchStarted extends GroupsEvent {
  const GroupsWatchStarted();
}

/// Internal: Firestore pushed a new list (or an error).
final class _GroupsUpdated extends GroupsEvent {
  final Either<Failure, List<Group>> result;
  const _GroupsUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
