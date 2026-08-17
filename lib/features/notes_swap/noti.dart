import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/features/notes_swap/searchScreen.dart';

import '../../Constents/AppConstents.dart';
import '../../Widgets/Buttons/BackWidgets.dart';
import 'AddNotesPage.dart';
import 'FeedScreen.dart';

class NoteSwapNotificationScreen extends StatefulWidget {
  const NoteSwapNotificationScreen({super.key});

  @override
  State<NoteSwapNotificationScreen> createState() =>
      _NoteSwapNotificationScreenState();
}

class _NoteSwapNotificationScreenState
    extends State<NoteSwapNotificationScreen> {
  final LightModeController lightModeController =
      Get.put(LightModeController());

  int _selectedTab = 0; // 0: Purchased Notes, 1: Note Alerts

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
            "Note Activity",
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
            // 1. TOP QUICK NAVIGATION BAR
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
              child: _QuickNavBar(isLight: isLight),
            ),

            const SizedBox(height: 12),

            // 2. TOGGLE FILTER TABS (Purchased Notes vs Note Alerts)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? brandPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 14,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "My Purchased Notes",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedTab == 0
                                      ? Colors.white
                                      : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? brandPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 14,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Note Alerts",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedTab == 1
                                      ? Colors.white
                                      : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. TAB CONTENT STREAMED FROM FIREBASE
            Expanded(
              child: _selectedTab == 0
                  ? _buildBoughtNotesList(
                      cardColor, textPrimary, textSecondary, brandPrimary)
                  : _buildNoteAlertsList(
                      cardColor, textPrimary, textSecondary, brandPrimary),
            ),
          ],
        ),
      );
    });
  }

  // --- PURCHASED / BOUGHT NOTES LIST BUILDER (collection: bought_notes) ---
  Widget _buildBoughtNotesList(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color brandPrimary,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bought_notes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.hasData ? snapshot.data!.docs : [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              "No notes purchased or saved yet.",
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final item = docs[index].data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: brandPrimary.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: brandPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item["department"] ?? "General Notes",
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: brandPrimary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  item["date"] ?? "Recently",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["title"] ??
                                  item["courseName"] ??
                                  "Class Lecture Note",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Uploaded by: ${item["seller"] ?? 'Student'} • File Size: ${item["size"] ?? '12.4 MB'}",
                              style: TextStyle(
                                fontSize: 9,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["isFree"] == true
                            ? "Free Note"
                            : "Paid ${item["price"] ?? '₹49'}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            "Opening Document",
                            "Opening ${item["title"] ?? 'Note PDF'}",
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded,
                            size: 14, color: Colors.white),
                        label: const Text(
                          "Read / Download PDF",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

  // --- SEPARATE NOTE ALERTS LIST BUILDER (collection: note_alerts) ---
  Widget _buildNoteAlertsList(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color brandPrimary,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('note_alerts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.hasData ? snapshot.data!.docs : [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              "No new note updates or activity.",
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final item = docs[index].data() as Map<String, dynamic>;
            final isEarning = item["type"] == "earning";

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isEarning
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : brandPrimary.withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isEarning
                        ? const Color(0xFF10B981).withOpacity(0.12)
                        : brandPrimary.withOpacity(0.12),
                    child: Icon(
                      isEarning
                          ? Icons.monetization_on_rounded
                          : Icons.note_add_rounded,
                      color: isEarning ? const Color(0xFF10B981) : brandPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item["title"] ?? "Note Update",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              item["time"] ?? "Recently",
                              style:
                                  TextStyle(fontSize: 8, color: textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item["message"] ??
                              "Your note has been accessed by students.",
                          style: TextStyle(fontSize: 10, color: textSecondary),
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
    );
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
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.off(() => const NoteSwapSearchScreen()),
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
            isActive: true,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () {},
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
