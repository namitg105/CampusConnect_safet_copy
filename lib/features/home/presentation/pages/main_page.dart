import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/community/presentation/pages/create_group_page.dart';
import 'package:noteswap/features/dashboard/presentation/pages/dashboard_page_one.dart';
import 'package:noteswap/features/notes/presentation/pages/notes_screen.dart';
import 'package:noteswap/features/notes/presentation/pages/upload_notes_screen.dart';
import 'package:noteswap/features/private_chat/page_controller.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:noteswap/features/posts/presentation/posts_navigation.dart';
import 'package:noteswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noteswap/features/home/presentation/bloc/main_nav_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../community/presentation/bloc/groups/groups_bloc.dart';
import '../../../community/presentation/bloc/membership/membership_bloc.dart';
import '../../../community/presentation/pages/groups_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navBloc = context.read<MainNavBloc>();
    const Color brandPrimary = Color(0xFF6366F1);
    const Color textDark = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);

    void handleCenterButtonTap() {
      final index = navBloc.state.currentIndex;
      if (index == 0) {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          PostsNavigation.openCreatePost(currentUser: authState.user);
        }
      } else if (index == 1) {
        AppNavigator.push(const CreateGroupPage(collegeId: ""));
      } else if (index == 4) {
        navBloc.add(const PrivateChatTabSelected(3));
      }
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<GroupsBloc>(create: (_) => sl<GroupsBloc>()),
        BlocProvider<MembershipBloc>(
          create: (_) =>
              sl<MembershipBloc>()..add(MembershipWatchStarted(userId)),
        ),
      ],
      child: BlocBuilder<MainNavBloc, MainNavState>(
        builder: (context, nav) => Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: nav.currentIndex,
            children: [
              const DashboardPageOne(),
              const GroupsPage(),
              const UploadNotesScreen(),
              const NotesScreen(),
              const PrivateChatPageController(),
              const ProfileSettingsPage(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                height: 64,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // The pill-shaped bar itself.
                    Positioned.fill(
                      top: 12, // leaves room for the center button to overlap
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1FE),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: textDark.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _NavBarIcon(
                                assetPath: 'assets/community/home_nav.png',
                                label: 'Home',
                                isSelected:
                                    nav.currentIndex == 0,
                                activeColor: brandPrimary,
                                inactiveColor: textMuted,
                                onTap: () => navBloc.add(const MainNavTabSelected(0)),
                              ),
                            ),
                            Expanded(
                              child: _NavBarIcon(
                                assetPath: 'assets/community/comm_nav.png',
                                label: 'Community',
                                isSelected:
                                    nav.currentIndex == 1,
                                activeColor: brandPrimary,
                                inactiveColor: textMuted,
                                onTap: () => navBloc.add(const MainNavTabSelected(1)),
                              ),
                            ),
                            Expanded(
                              child: _NavBarIcon(
                                icon: Icons.upload_file,
                                label: 'Upload',
                                isSelected:
                                    nav.currentIndex == 2,
                                activeColor: brandPrimary,
                                inactiveColor: textMuted,
                                onTap: () => navBloc.add(const MainNavTabSelected(2)),
                              ),
                            ),
                            // Empty space the floating center button sits over.
                            const SizedBox(width: 56),
                            Expanded(
                              child: _NavBarIcon(
                                icon: Icons.menu_book,
                                label: 'Notes',
                                isSelected:
                                    nav.currentIndex == 3,
                                activeColor: brandPrimary,
                                inactiveColor: textMuted,
                                onTap: () => navBloc.add(const MainNavTabSelected(3)),
                              ),
                            ),
                            Expanded(
                              child: _NavBarIcon(
                                assetPath: 'assets/community/msg_nav.png',
                                label: 'Messages',
                                isSelected:
                                    nav.currentIndex == 4,
                                activeColor: brandPrimary,
                                inactiveColor: textMuted,
                                onTap: () => navBloc.add(const MainNavTabSelected(4)),
                              ),
                            ),
                            Expanded(
                              child: _NavBarIcon(
                                assetPath: 'assets/community/prof_nav.png',
                                label: 'Profile',
                                isSelected:
                                    nav.currentIndex == 5,
                                activeColor: brandPrimary,
                                inactiveColor: textMuted,
                                onTap: () => navBloc.add(const MainNavTabSelected(5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: _CreateButton(
                        color: brandPrimary,
                        onTap: handleCenterButtonTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarIcon({
    this.assetPath,
    this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (assetPath != null)
            Image.asset(
              assetPath!,
              width: 20,
              height: 20,
              color: color,
            )
          else if (icon != null)
            Icon(
              icon,
              size: 20,
              color: color,
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _CreateButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
