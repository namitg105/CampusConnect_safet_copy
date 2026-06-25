import '../repos/profile_repo.dart';

class GetProfileUseCase {
  final ProfileRepo repository;

  GetProfileUseCase({required this.repository});

  Future<Map<String, dynamic>?> call(String userId) async {
    return repository.getUserProfile(userId);
  }
}
