part of 'create_post_bloc.dart';

enum CreatePostStatus { initial, submitting, success, failure }

final class CreatePostState extends Equatable {
  final CreatePostStatus status;
  final String errorMessage;

  const CreatePostState({
    this.status = CreatePostStatus.initial,
    this.errorMessage = '',
  });

  bool get isSubmitting => status == CreatePostStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage];
}
