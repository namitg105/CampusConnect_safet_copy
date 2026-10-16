import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/group.dart';
import '../../../domain/usecases/group_usecases.dart';

part 'create_group_event.dart';
part 'create_group_state.dart';

/// Drives the Create Community form.
class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final CreateGroup _createGroup;

  CreateGroupBloc({required CreateGroup createGroup})
      : _createGroup = createGroup,
        super(const CreateGroupState()) {
    on<CreateGroupSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateGroupSubmitted event,
    Emitter<CreateGroupState> emit,
  ) async {
    if (event.creatorId.isEmpty) {
      emit(const CreateGroupState(
        status: CreateGroupStatus.failure,
        errorMessage: 'User not logged in',
      ));
      return;
    }
    emit(const CreateGroupState(status: CreateGroupStatus.submitting));

    final result = await _createGroup(Group(
      id: '',
      name: event.name.trim(),
      collegeId: event.collegeId,
      description: event.description.trim(),
      category: event.category,
      isPublic: event.isPublic,
      rules: event.rules,
      memberCount: 0,
      maxMembers: 50,
      remainingSeats: 50,
      createdBy: event.creatorId,
      imageUrl: '',
      createdAt: DateTime.now(),
    ));

    result.fold(
      (failure) => emit(CreateGroupState(
        status: CreateGroupStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(const CreateGroupState(status: CreateGroupStatus.success)),
    );
  }
}
