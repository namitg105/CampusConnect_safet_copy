import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/posts/data/profile_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/get_profile_usecase.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

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
    final LightModeController lightModeController = Get.find<LightModeController>();
    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;
      final textColor = isLightMode ? Colors.black : Colors.white;
      final labelColor = isLightMode ? Colors.grey[600] : Colors.grey[400];

      return Scaffold(
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: isLightMode ? Colors.black : Colors.white,
          iconTheme: IconThemeData(color: isLightMode ? Colors.white : Colors.black),
          title: Text(
            'Profile',
            style: TextStyle(
              color: isLightMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF6139ED).withOpacity(0.2),
                        child: const Icon(Icons.person, size: 50, color: Color(0xFF6139ED)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Name Section
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 22, color: Color(0xFF6139ED)),
                        const SizedBox(width: 12),
                        Text(
                          'Name: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: labelColor),
                        ),
                        Expanded(
                          child: Text(
                            profileData?['name'] ?? (widget.user.name.isNotEmpty ? widget.user.name : "N/A"),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Email Section
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 22, color: Color(0xFF6139ED)),
                        const SizedBox(width: 12),
                        Text(
                          'Email: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: labelColor),
                        ),
                        Expanded(
                          child: Text(
                            profileData?['email'] ?? widget.user.email,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // College Section
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 22, color: Color(0xFF6139ED)),
                        const SizedBox(width: 12),
                        Text(
                          'College: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: labelColor),
                        ),
                        Expanded(
                          child: Text(
                            profileData?['collegeId'] ?? widget.user.collegeId,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6139ED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}
