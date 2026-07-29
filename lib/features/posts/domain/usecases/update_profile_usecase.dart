import '../repos/profile_repo.dart';

class UpdateProfileUseCase {
  final ProfileRepo repository;

  UpdateProfileUseCase({required this.repository});

  Future<void> call(String userId, Map<String, dynamic> data) async {
    return repository.updateUserProfile(userId, data);
  }
}
