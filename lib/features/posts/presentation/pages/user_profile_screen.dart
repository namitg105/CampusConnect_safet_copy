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
    try {
      if (widget.user.uid.isNotEmpty) {
        final data = await profileUseCase.call(widget.user.uid);
        if (mounted) {
          setState(() {
            profileData = data;
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    final cleanName = name.contains('@') ? name.split('@').first : name;
    if (cleanName.trim().isEmpty) return '?';
    final parts = cleanName.trim().split(RegExp(r'[\s._-]+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return cleanName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final LightModeController lightModeController =
        Get.find<LightModeController>();
    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;
      final textColor = isLightMode ? Colors.black87 : Colors.white;
      final labelColor = isLightMode ? Colors.grey[600] : Colors.grey[400];
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E1E);

      final rawName = profileData?['name'] ??
          profileData?['displayName'] ??
          (widget.user.name.isNotEmpty ? widget.user.name : "User");
      final name = rawName.contains('@') ? rawName.split('@').first : rawName;

      final email = profileData?['email'] ??
          (widget.user.email.isNotEmpty ? widget.user.email : "Not provided");

      final profileImage = profileData?['profileImage'] ??
          profileData?['imageUrl'] ??
          profileData?['photoUrl'] ??
          '';

      final initials = _getInitials(name);

      return Scaffold(
        backgroundColor:
            isLightMode ? const Color(0xFFF8F9FE) : const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6139ED),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            const Color(0xFF6139ED).withOpacity(0.15),
                        backgroundImage: profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage.isEmpty
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6139ED),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Details Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isLightMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6139ED).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_outline,
                                    size: 20, color: Color(0xFF6139ED)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Full Name',
                                      style: TextStyle(
                                          fontSize: 11, color: labelColor),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(height: 1),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6139ED).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.email_outlined,
                                    size: 20, color: Color(0xFF6139ED)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email Address',
                                      style: TextStyle(
                                          fontSize: 11, color: labelColor),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}
