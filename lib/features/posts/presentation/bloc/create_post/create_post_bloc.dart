import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/entities/app_user.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/create_post_usecase.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

/// Drives the Create Post screen: validate, save, report success/failure.
class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostUseCase _createPost;

  CreatePostBloc({required CreatePostUseCase createPost})
      : _createPost = createPost,
        super(const CreatePostState()) {
    on<CreatePostSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreatePostSubmitted event,
    Emitter<CreatePostState> emit,
  ) async {
    if (event.title.trim().isEmpty || event.body.trim().isEmpty) {
      emit(const CreatePostState(
        status: CreatePostStatus.failure,
        errorMessage: 'Title and body cannot be empty.',
      ));
      return;
    }
    emit(const CreatePostState(status: CreatePostStatus.submitting));

    final author = event.author;
    final result = await _createPost(PostEntity(
      id: '',
      title: event.title.trim(),
      body: event.body.trim(),
      authorId: author.uid,
      authorName: author.name.isNotEmpty
          ? author.name
          : (author.email.contains('@')
              ? author.email.split('@').first
              : author.email),
      collegeId: author.collegeId,
      upvotes: 0,
      commentCount: 0,
      tag: event.tag,
      createdAt: DateTime.now(),
      // TODO: upload the file (Firebase Storage) and store its real URL.
      // Kept as before: attachments are not uploaded yet.
      imageUrl: event.imagePath != null && event.imageName != null
          ? 'dummy_image_url'
          : null,
      mediaType: event.mediaType,
      mediaName: event.mediaName,
      poll: event.poll,
    ));

    result.fold(
      (failure) => emit(CreatePostState(
        status: CreatePostStatus.failure,
        errorMessage: 'Unable to create post: ${failure.message}',
      )),
      (_) => emit(const CreatePostState(status: CreatePostStatus.success)),
    );
  }
}
