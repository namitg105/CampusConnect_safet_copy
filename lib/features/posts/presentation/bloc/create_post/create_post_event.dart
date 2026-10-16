part of 'create_post_bloc.dart';

sealed class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

final class CreatePostSubmitted extends CreatePostEvent {
  final String title;
  final String body;
  final AppUser author;
  final String tag;
  final String? imagePath;
  final String? imageName;
  final String? mediaType;
  final String? mediaName;
  final PollData? poll;

  const CreatePostSubmitted({
    required this.title,
    required this.body,
    required this.author,
    required this.tag,
    this.imagePath,
    this.imageName,
    this.mediaType,
    this.mediaName,
    this.poll,
  });

  @override
  List<Object?> get props => [
        title,
        body,
        author,
        tag,
        imagePath,
        imageName,
        mediaType,
        mediaName,
        poll,
      ];
}
