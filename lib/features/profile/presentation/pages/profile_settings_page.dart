import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/private_chat/page_controller.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/posts/data/profile_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/get_profile_usecase.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            child: Icon(Icons.school, color: brandColor, size: 24),
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
                            icon: Icon(Icons.notifications_none, color: textColor),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.settings_outlined, color: textColor),
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
                                        backgroundColor: brandColor.withOpacity(0.15),
                                        child: Text(
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
                                          'Mtech Software engineer, 4th year',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textColor.withOpacity(0.8),
                                          ),
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
                                                  overflow: TextOverflow.ellipsis,
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
                                    onPressed: () {},
                                    icon: Icon(Icons.edit_outlined,
                                        color: brandColor, size: 22),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Account Heading
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 12),
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
                                      subTextColor),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.palette_outlined,
                                      'Theme',
                                      'Choose your preferred theme',
                                      brandColor,
                                      textColor,
                                      subTextColor),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.notifications_none,
                                      'Notifications',
                                      'Manage your notification preferences',
                                      brandColor,
                                      textColor,
                                      subTextColor),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.security_outlined,
                                      'Privacy & Security',
                                      'Manage your privacy and security settings',
                                      brandColor,
                                      textColor,
                                      subTextColor),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.help_outline,
                                      'Help & Support',
                                      'Get help and contact support',
                                      brandColor,
                                      textColor,
                                      subTextColor),
                                  _buildDivider(isLightMode),
                                  _buildSettingItem(
                                      Icons.info_outline,
                                      'About UniConnect',
                                      'Learn more about app',
                                      brandColor,
                                      textColor,
                                      subTextColor),
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
                                onTap: () {
                                  context.read<AuthCubit>().logout();
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
          // Premium floating navigation bar layout
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: _buildNavItem(
                      Icons.home, 'Home', false, brandColor, subTextColor),
                ),
                _buildNavItem(Icons.people_outline, 'Communities', false,
                    brandColor, subTextColor),
                // Floating center button
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: brandColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: brandColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                 GestureDetector(
                   onTap: () => Get.to(() => const PrivateChatPageController()),
                   child: _buildNavItem(Icons.chat_bubble_outline, 'Messages', false,
                       brandColor, subTextColor),
                 ),
                _buildNavItem(Icons.person, 'Profile', true, brandColor,
                    subTextColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle,
      Color iconColor, Color textColor, Color? subTextColor) {
    return Padding(
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
    );
  }

  Widget _buildDivider(bool isLightMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: isLightMode ? Colors.grey[200] : Colors.grey[800],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected,
      Color brandColor, Color? unselectedColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? brandColor : unselectedColor,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? brandColor : unselectedColor,
          ),
        ),
      ],
    );
  }
}
