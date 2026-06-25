import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/data/profile_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/get_profile_usecase.dart';

class UserProfileScreen extends StatefulWidget {
  final AppUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final GetProfileUseCase profileUseCase;
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    profileUseCase = GetProfileUseCase(repository: ProfileRepoImpl());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await profileUseCase.call(widget.user.uid);
    setState(() {
      profileData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    child: Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileData?['name'] ?? widget.user.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(profileData?['email'] ?? widget.user.email),
                  const SizedBox(height: 8),
                  Text('College: ${profileData?['collegeId'] ?? widget.user.collegeId}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
    );
  }
}
