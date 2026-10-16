part of 'create_group_bloc.dart';

enum CreateGroupStatus { initial, submitting, success, failure }

final class CreateGroupState extends Equatable {
  final CreateGroupStatus status;
  final String errorMessage;

  const CreateGroupState({
    this.status = CreateGroupStatus.initial,
    this.errorMessage = '',
  });

  bool get isSubmitting => status == CreateGroupStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage];
}
