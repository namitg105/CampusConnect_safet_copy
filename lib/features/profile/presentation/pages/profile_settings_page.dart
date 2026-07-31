import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/auth/presentation/pages/SplashScreen.dart';
import 'package:noteswap/features/posts/data/profile_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/get_profile_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/update_profile_usecase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final GetProfileUseCase profileUseCase;
  late final UpdateProfileUseCase updateProfileUseCase;
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final repo = ProfileRepoImpl();
    profileUseCase = GetProfileUseCase(repository: repo);
    updateProfileUseCase = UpdateProfileUseCase(repository: repo);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final data = await profileUseCase.call(authState.user.uid);
      if (mounted) {
        setState(() {
          profileData = data;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getInitials(String name, String email) {
    final displayName = name.isNotEmpty
        ? name
        : (email.contains('@') ? email.split('@').first : email);
    if (displayName.trim().isEmpty) return '?';
    final parts = displayName.trim().split(RegExp(r'[\s._-]+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final backgroundColor =
        isLightMode ? const Color(0xFFF9F9FB) : const Color(0xFF121212);
    final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E1E);
    final textColor = isLightMode ? Colors.black87 : Colors.white;
    final subTextColor = isLightMode ? Colors.grey[600] : Colors.grey[400];
    final brandColor = const Color(0xFF6139ED);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(
              child: Text('Please login to view profile'),
            ),
          );
        }

        final user = authState.user;
        final name = profileData?['name'] ??
            (user.name.isNotEmpty
                ? user.name
                : (user.email.contains('@')
                    ? user.email.split('@').first
                    : user.email));
        final email = profileData?['email'] ?? user.email;
        final initials = getInitials(name, email);

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: Icon(Icons.arrow_back, color: textColor),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                Icon(Icons.school, color: brandColor, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'uniConnect',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: brandColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon:
                                Icon(Icons.settings_outlined, color: textColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6139ED),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Profile Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar with active green dot
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundColor:
                                            brandColor.withOpacity(0.15),
                                        backgroundImage: (profileData?[
                                                        'profileImage'] !=
                                                    null &&
                                                (profileData?['profileImage']
                                                        as String)
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                                profileData?['profileImage'])
                                            : null,
                                        child: (profileData?['profileImage'] !=
                                                    null &&
                                                (profileData?['profileImage']
                                                        as String)
                                                    .isNotEmpty)
                                            ? null
                                            : Text(
                                                initials,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: brandColor,
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 2,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00BFA5),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: cardColor, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(Icons.verified,
                                                color: brandColor, size: 18),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (profileData != null &&
                                                  profileData!['bio'] != null &&
                                                  profileData!['bio']
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty)
                                              ? profileData!['bio'].toString()
                                              : 'No bio added yet',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textColor.withOpacity(0.8),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        // Email label
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: brandColor.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.mail_outline,
                                                  size: 14, color: brandColor),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  email,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: brandColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Edit profile button
                                  IconButton(
                                    onPressed: () => _showEditProfileModal(),
                                    icon: Icon(Icons.edit_outlined,
                                        color: brandColor, size: 22),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Account Heading
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 12),
                              child: Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),

                            // Settings items group
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildSettingItem(
                                      Icons.person_outline,
                                      'Account',
                                      'Update your personal information',
                                      brandColor,
                                      textColor,
                                      subTextColor,
                                      onTap: () =>
                                          _showComingSoonDialog('Account')),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.palette_outlined,
                                      'Theme',
                                      'Choose your preferred theme',
                                      brandColor,
                                      textColor,
                                      subTextColor,
                                      onTap: () =>
                                          _showComingSoonDialog('Theme')),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.notifications_none,
                                      'Notifications',
                                      'Manage your notification preferences',
                                      brandColor,
                                      textColor,
                                      subTextColor,
                                      onTap: () => _showComingSoonDialog(
                                          'Manage Notifications')),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.security_outlined,
                                      'Privacy & Security',
                                      'Manage your privacy and security settings',
                                      brandColor,
                                      textColor,
                                      subTextColor,
                                      onTap: () => _showComingSoonDialog(
                                          'Privacy & Security Management')),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.help_outline,
                                      'Help & Support',
                                      'Get help and contact support',
                                      brandColor,
                                      textColor,
                                      subTextColor,
                                      onTap: () => _showHelpSupportDialog()),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.info_outline,
                                      'More about Valsco-Tech',
                                      'Company behind UniConnect',
                                      brandColor,
                                      textColor,
                                      subTextColor,
                                      onTap: () =>
                                          _showAboutUniConnectDialog()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Logout Card
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  try {
                                    await context.read<AuthCubit>().logout();
                                  } catch (e) {
                                    print("Logout error: $e");
                                  }
                                  Get.offAll(() => SplashScreen());
                                },
                                child: _buildSettingItem(
                                  Icons.logout_outlined,
                                  'Logout',
                                  'Sign out from your account',
                                  Colors.redAccent,
                                  Colors.redAccent,
                                  subTextColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 80), // bottom nav space
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(String settingName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Color(0xFF6139ED),
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  settingName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "This $settingName feature will be working in the next update!",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6139ED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Color(0xFF6139ED),
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'Help & Support',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        content: const Text(
          "Please mail jurident@gmail.com for any issue or if you need any help with the app",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6139ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutUniConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Color(0xFF6139ED),
              size: 26,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'About Valsco-Tech',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final Uri url = Uri.parse("https://valscotech.com/");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  await launchUrl(url);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF6139ED).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        " Valsco-Tech",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6139ED),
                        ),
                      ),
                    ),
                    Icon(Icons.open_in_new, color: Color(0xFF6139ED), size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6139ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle,
      Color iconColor, Color textColor, Color? subTextColor,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isLightMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: isLightMode ? Colors.grey[200] : Colors.grey[800],
    );
  }

  void _showEditProfileModal() {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final primaryColor = const Color(0xFF6139ED);
    final cardBg = isLightMode ? Colors.white : const Color(0xFF1E1E1E);
    final inputBg = isLightMode ? Colors.grey[100] : const Color(0xFF2A2A2A);
    final textColor = isLightMode ? Colors.black87 : Colors.white;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;
    final userId = authState.user.uid;

    File? pickedImage;
    bool resetToDefault = false;
    bool isSaving = false;
    final bioController =
        TextEditingController(text: profileData?['bio'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String name = profileData?['name'] ?? authState.user.name;
            final String email = profileData?['email'] ?? authState.user.email;
            final String initials = getInitials(name, email);

            ImageProvider? avatarImage;
            if (!resetToDefault) {
              if (pickedImage != null) {
                avatarImage = FileImage(pickedImage!);
              } else if (profileData?['profileImage'] != null &&
                  (profileData?['profileImage'] as String).isNotEmpty) {
                avatarImage = NetworkImage(profileData?['profileImage']);
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pull bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Image selection UI
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withOpacity(0.15),
                          backgroundImage: avatarImage,
                          child: avatarImage != null
                              ? null
                              : Text(
                                  initials,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 70,
                                );
                                if (image != null) {
                                  setModalState(() {
                                    pickedImage = File(image.path);
                                    resetToDefault = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            pickedImage = null;
                            resetToDefault = true;
                          });
                        },
                        child: const Text(
                          'Use Default Avatar',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bio Edit Input
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Tell us about yourself...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setModalState(() {
                                    isSaving = true;
                                  });

                                  try {
                                    String? profileImageUrl =
                                        profileData?['profileImage'];

                                    if (resetToDefault) {
                                      profileImageUrl = "";
                                      try {
                                        final storageRef = FirebaseStorage
                                            .instance
                                            .ref()
                                            .child(
                                                'profile_pictures/$userId.jpg');
                                        await storageRef.delete();
                                      } catch (_) {}
                                    } else if (pickedImage != null) {
                                      final storageRef =
                                          FirebaseStorage.instance.ref().child(
                                              'profile_pictures/$userId.jpg');
                                      await storageRef.putFile(pickedImage!);
                                      profileImageUrl =
                                          await storageRef.getDownloadURL();
                                    }

                                    await updateProfileUseCase.call(userId, {
                                      'bio': bioController.text.trim(),
                                      'profileImage': profileImageUrl ?? "",
                                    });

                                    // Close the sheet safely
                                    if (context.mounted) Navigator.pop(context);

                                    _loadProfile();

                                    Get.snackbar(
                                      'Success',
                                      'Profile updated successfully',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF6139ED),
                                      colorText: Colors.white,
                                    );
                                  } catch (e) {
                                    setModalState(() {
                                      isSaving = false;
                                    });
                                    Get.snackbar(
                                      'Error',
                                      'Failed to update profile: $e',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
