import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Views/AddUsers.dart';
import 'package:noteswap/Views/Notification.dart';
import 'package:noteswap/Views/SearchScreen.dart';
import '../Constents/AppConstents.dart';
import '../ViewModels/ImageSectionViewModels.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/ImageSelection/ImageSectionWidget.dart';
import '../Widgets/ImageSelection/ImageSectionWidgetThree.dart';
import '../Widgets/ImageSelection/ImageSectionWidgetTwo.dart';
import '../features/home/presentation/pages/main_page.dart';

class FeedScreen extends StatelessWidget {
  final ImageSectionController imageController =
      Get.put(ImageSectionController());
  final LightModeController lightModeController =
      Get.put(LightModeController());

  FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLight = lightModeController.isLightMode.value;

      // Color Palette Definition
      final bgColor =
          isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
      final cardColor = isLight ? Colors.white : const Color(0xFF1E293B);
      final textPrimary = isLight ? const Color(0xFF0F172A) : Colors.white;
      final textSecondary =
          isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      const brandPrimary = Color(0xFF6366F1);
      const brandSecondary = Color(0xFF4F46E5);

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: isLight ? Colors.white : const Color(0xFF0F172A),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackWidget(
              onTap: () => Get.off(() => const MainPage()),
              imagePath: isLight
                  ? AppConstants.backBlackIcon
                  : AppConstants.backWhiteIcon,
            ),
          ),
          title: Text(
            AppConstants.noteSwapTexts,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isLight ? Icons.settings_outlined : Icons.settings,
                color: textPrimary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO HEADER BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF0F172A),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back 👋",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Explore Study Materials",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: brandPrimary.withOpacity(0.12),
                          child: const Icon(
                            Icons.school_rounded,
                            color: brandPrimary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2. TOP QUICK NAVIGATION BAR
                    _QuickNavBar(isLight: isLight),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. SEARCH & QUICK FILTERS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: brandPrimary.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: brandPrimary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Search subject, course, or department...",
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: brandPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: brandPrimary, size: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. MAIN BODY SECTIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION 1: LIBRARY OPTIONS ---
                    _SectionHeader(
                      title: "Explore Library",
                      subtitle: "Quickly access categories & features",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _LibraryCategoryCard(
                            icon: Icons.menu_book_rounded,
                            label: "Available\nNotes",
                            badgeText: "1.2k",
                            color: const Color(0xFF6366F1),
                            isLight: isLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LibraryCategoryCard(
                            icon: Icons.auto_awesome_rounded,
                            label: "Newly\nAdded",
                            badgeText: "New",
                            color: const Color(0xFF10B981),
                            isLight: isLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LibraryCategoryCard(
                            icon: Icons.local_fire_department_rounded,
                            label: "Top\nSelling",
                            badgeText: "Hot",
                            color: const Color(0xFFF59E0B),
                            isLight: isLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- SECTION 2: DEPARTMENTS ---
                    _SectionHeader(
                      title: "Departments",
                      subtitle: "Browse study notes by engineering fields",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    ImageSectionWidget(controller: imageController),

                    const SizedBox(height: 24),

                    // --- SECTION 3: HANDWRITTEN NOTES ---
                    _SectionHeader(
                      title: "Handwritten Notes",
                      subtitle: "Verified student notes for exam prep",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    ImageSectionWidgetTwo(controller: imageController),

                    const SizedBox(height: 24),

                    // --- SECTION 4: SELL YOUR NOTES ---
                    _SectionHeader(
                      title: "Monetize Notes",
                      subtitle: "Share your knowledge and earn money",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    ImageSectionWidgetThree(controller: imageController),

                    const SizedBox(height: 24),

                    // --- SECTION 5: CALL TO ACTION BANNER ---
                    _RequestNotesBanner(
                      isLight: isLight,
                      brandPrimary: brandPrimary,
                      brandSecondary: brandSecondary,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 28),
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

/// Horizontal Navigation Tabs Header Widget
class _QuickNavBar extends StatelessWidget {
  final bool isLight;

  const _QuickNavBar({required this.isLight});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF6366F1);
    final cardBg = isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final textColor =
        isLight ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _NavChip(
            icon: Icons.grid_view_rounded,
            label: 'Feed',
            isActive: true,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () {},
          ),
          _NavChip(
            icon: Icons.search_rounded,
            label: 'Search',
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.to(() => SearchScreen()),
          ),
          _NavChip(
            icon: Icons.note_add_rounded,
            label: 'Add Notes',
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.to(() => AddUsers()),
          ),
          _NavChip(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.to(() => NotificationScreen()),
          ),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _NavChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isActive ? activeColor : bgColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? Colors.white : activeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header with primary title and subtitle
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textPrimary;
  final Color textSecondary;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Category Option Item Card
class _LibraryCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badgeText;
  final Color color;
  final bool isLight;

  const _LibraryCategoryCard({
    required this.icon,
    required this.label,
    required this.badgeText,
    required this.color,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: isLight ? const Color(0xFF0F172A) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Call-to-Action Card Banner
class _RequestNotesBanner extends StatelessWidget {
  final bool isLight;
  final Color brandPrimary;
  final Color brandSecondary;
  final Color textPrimary;
  final Color textSecondary;

  const _RequestNotesBanner({
    required this.isLight,
    required this.brandPrimary,
    required this.brandSecondary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)]
              : [const Color(0xFF1E1B4B), const Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandPrimary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: brandPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "COMMUNITY HELP",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Can't find your notes?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Request specific study guides from classmates.",
                  style: TextStyle(
                    fontSize: 10,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Request Notes",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.find_in_page_rounded,
            size: 48,
            color: brandPrimary.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
