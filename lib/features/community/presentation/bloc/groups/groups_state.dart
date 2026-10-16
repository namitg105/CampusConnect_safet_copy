part of 'groups_bloc.dart';

sealed class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

final class GroupInitial extends GroupState {
  const GroupInitial();
}

final class GroupLoading extends GroupState {
  const GroupLoading();
}

final class GroupLoaded extends GroupState {
  final List<Group> groups;
  const GroupLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

final class GroupError extends GroupState {
  final String message;
  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}
