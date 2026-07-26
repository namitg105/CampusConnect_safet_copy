import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/community/presentation/pages/create_group_page.dart';
import 'package:noteswap/features/events/presentation/screens/create_event.dart';
import 'package:noteswap/features/group_chat/presentation/pages/groups_page.dart';
import 'package:noteswap/features/home/presentation/pages/home_page.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_page.dart';

import '../../../../core/di/injection.dart';
import '../../../community/presentation/cubits/group_cubit.dart';
import '../../../community/presentation/pages/groups_page.dart';
import '../../../group_chat/presentation/pages/new_group.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const Color _brandPrimary = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  void _navigateToCreateGroup() {}

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupCubit>(
      create: (_) => sl<GroupCubit>(),
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomePage(),
            const GroupsPage(),
            const GroupsDisplayPage(),
            UserProfilePage()
            //   CreateEventPage()
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SizedBox(
              height: 70,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // The pill-shaped bar itself.
                  Positioned.fill(
                    top: 14, // leaves room for the center button to overlap
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F1FE),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _textDark.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _NavBarIcon(
                            assetPath: 'assets/community/home_nav.png',
                            label: 'Home',
                            isSelected: _currentIndex == 0,
                            activeColor: _brandPrimary,
                            inactiveColor: _textMuted,
                            onTap: () => setState(() => _currentIndex = 0),
                          ),
                          _NavBarIcon(
                            assetPath: 'assets/community/comm_nav.png',
                            label: 'Community',
                            isSelected: _currentIndex == 1,
                            activeColor: _brandPrimary,
                            inactiveColor: _textMuted,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          // Empty space the floating center button sits over.
                          const SizedBox(width: 56),
                          _NavBarIcon(
                            assetPath: 'assets/community/msg_nav.png',
                            label: 'Messages',
                            isSelected: _currentIndex == 2,
                            activeColor: _brandPrimary,
                            inactiveColor: _textMuted,
                            onTap: () => setState(() => _currentIndex = 2),
                          ),
                          _NavBarIcon(
                            assetPath: 'assets/community/prof_nav.png',
                            label: 'Profile',
                            isSelected: _currentIndex == 3,
                            activeColor: _brandPrimary,
                            inactiveColor: _textMuted,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Elevated center create button, popping above the bar.
                  Positioned(
                    top: 0,
                    child: _CreateButton(
                      color: _brandPrimary,
                      onTap: _navigateToCreateGroup,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarIcon({
    this.icon,
    this.assetPath,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  }) : assert(
          icon != null || assetPath != null,
          'Either icon or assetPath must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final currentColor = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetPath != null)
              Image.asset(
                assetPath!,
                width: 20,
                height: 20,
                color:
                    currentColor, // Tint the asset with active/inactive color
                errorBuilder: (_, __, ___) => Icon(
                  Icons.groups_rounded,
                  size: 20,
                  color: currentColor,
                ),
              )
            else
              Icon(
                icon,
                size: 20,
                color: currentColor,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: currentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _CreateButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
