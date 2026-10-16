part of 'create_group_bloc.dart';

sealed class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object?> get props => [];
}

final class CreateGroupSubmitted extends CreateGroupEvent {
  final String name;
  final String description;
  final String collegeId;
  final String category;
  final bool isPublic;
  final List<String> rules;
  final String creatorId;

  const CreateGroupSubmitted({
    required this.name,
    required this.description,
    required this.collegeId,
    required this.category,
    required this.isPublic,
    required this.rules,
    required this.creatorId,
  });

  @override
  List<Object?> get props =>
      [name, description, collegeId, category, isPublic, rules, creatorId];
}
