import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Views/AddUsers.dart';
import 'package:noteswap/Views/Notification.dart';
import 'package:noteswap/features/notes_swap/AddNotesPage.dart';

import '../../Constents/AppConstents.dart';
import '../../Widgets/Buttons/BackWidgets.dart';
import 'FeedScreen.dart';
import 'noti.dart';

class NoteSwapSearchScreen extends StatefulWidget {
  const NoteSwapSearchScreen({super.key});

  @override
  State<NoteSwapSearchScreen> createState() => _NoteSwapSearchScreenState();
}

class _NoteSwapSearchScreenState extends State<NoteSwapSearchScreen> {
  final LightModeController lightModeController =
      Get.put(LightModeController());
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = "All";
  String searchQuery = "";

  final List<String> filterTags = [
    "All",
    "CSE",
    "ECE",
    "MECH",
    "CIVIL",
    "Free Notes"
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLight = lightModeController.isLightMode.value;

      final bgColor =
          isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
      final cardColor = isLight ? Colors.white : const Color(0xFF1E293B);
      final textPrimary = isLight ? const Color(0xFF0F172A) : Colors.white;
      final textSecondary =
          isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      const brandPrimary = Color(0xFF6366F1);

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: isLight ? Colors.white : const Color(0xFF0F172A),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackWidget(
              onTap: () => Get.back(),
              imagePath: isLight
                  ? AppConstants.backBlackIcon
                  : AppConstants.backWhiteIcon,
            ),
          ),
          title: Text(
            "Search Notes",
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
        body: Column(
          children: [
            // 1. TOP HEADER WITH QUICK NAV BAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                children: [
                  _QuickNavBar(isLight: isLight),
                  const SizedBox(height: 12),

                  // Interactive Search Field
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: brandPrimary.withOpacity(0.15),
                      ),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) =>
                          setState(() => searchQuery = val.trim()),
                      style: TextStyle(fontSize: 12, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "Search by subject, code, or professor...",
                        hintStyle: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: brandPrimary,
                          size: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.tune_rounded,
                            color: brandPrimary,
                            size: 16,
                          ),
                          onPressed: () {},
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. QUICK FILTER TAGS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: filterTags.map((tag) {
                    final isSelected = tag == selectedFilter;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = tag),
                      child: _FilterChip(
                        label: tag,
                        isSelected: isSelected,
                        isLight: isLight,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. SEARCH RESULTS LIST FROM FIREBASE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('notes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.hasData ? snapshot.data!.docs : [];

                  // Apply text search & category filter logic
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['courseName'] ?? data['title'] ?? '')
                        .toString()
                        .toLowerCase();
                    final dept =
                        (data['department'] ?? '').toString().toLowerCase();

                    bool matchesText =
                        title.contains(searchQuery.toLowerCase()) ||
                            dept.contains(searchQuery.toLowerCase());

                    if (!matchesText) return false;

                    if (selectedFilter == "All") return true;
                    if (selectedFilter == "Free Notes") {
                      return data['isFree'] == true ||
                          data['price'] == 0 ||
                          data['price'] == "Free";
                    }

                    return dept.contains(selectedFilter.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No matching notes found.",
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item =
                          filtered[index].data() as Map<String, dynamic>;

                      final title = item["courseName"] ??
                          item["title"] ??
                          "Untitled Note";
                      final department = item["department"] ?? "General";
                      final author = item["author"] ?? "Verified Student";
                      final isFree = item["isFree"] == true;
                      final price = isFree
                          ? "Free"
                          : "₹${item['price']?.toString() ?? '49'}";
                      final rating = item["rating"]?.toString() ?? "4.8";
                      final Color tagColor = isFree
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: tagColor.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Thumbnail Box
                            Container(
                              width: 46,
                              height: 52,
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.description_rounded,
                                color: tagColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Center Content Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tagColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          department,
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: tagColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        rating,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 11,
                                        color: textSecondary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        author,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        price,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: price == "Free"
                                              ? const Color(0xFF10B981)
                                              : brandPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

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
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.off(() => NoteSwapFeedScreen()),
          ),
          _NavChip(
            icon: Icons.search_rounded,
            label: 'Search',
            isActive: true,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () {},
          ),
          _NavChip(
            icon: Icons.note_add_rounded,
            label: 'Add Notes',
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.to(() => const AddNotesPage()),
          ),
          _NavChip(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.to(() => const NoteSwapNotificationScreen()),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLight;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    const brandPrimary = Color(0xFF6366F1);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? brandPrimary.withOpacity(0.12)
              : (isLight ? Colors.white : const Color(0xFF1E293B)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? brandPrimary
                : (isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? brandPrimary
                : (isLight ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          ),
        ),
      ),
    );
  }
}
