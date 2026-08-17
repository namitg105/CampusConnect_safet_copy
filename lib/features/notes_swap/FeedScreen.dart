import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Views/AddUsers.dart';
import 'package:noteswap/Views/Notification.dart';
import 'package:noteswap/features/notes_swap/AddNotesPage.dart';
import 'package:noteswap/features/notes_swap/noti.dart';
import 'package:noteswap/features/notes_swap/searchScreen.dart';

import '../../Constents/AppConstents.dart';
import '../../ViewModels/ImageSectionViewModels.dart';
import '../../Widgets/Buttons/BackWidgets.dart';
import '../home/presentation/pages/main_page.dart';

class NoteSwapFeedScreen extends StatelessWidget {
  final ImageSectionController imageController =
      Get.put(ImageSectionController());
  final LightModeController lightModeController =
      Get.put(LightModeController());

  NoteSwapFeedScreen({super.key});

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
                child: GestureDetector(
                  onTap: () => Get.to(() => const NoteSwapSearchScreen()),
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
                            style:
                                TextStyle(fontSize: 12, color: textSecondary),
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
                            badgeText: "Live",
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

                    // --- SECTION 2: DEPARTMENTS (HARDCODED DATA) ---
                    _SectionHeader(
                      title: "Departments",
                      subtitle: "Browse study notes by engineering fields",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    _DepartmentPhotoSection(isLight: isLight),

                    const SizedBox(height: 24),

                    // --- SECTION 3: HANDWRITTEN NOTES (FIREBASE STREAM & BUY CLICK) ---
                    _SectionHeader(
                      title: "Handwritten Notes",
                      subtitle: "Verified student notes for exam prep",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    _HandwrittenNotesPhotoSection(isLight: isLight),

                    const SizedBox(height: 24),

                    // --- SECTION 4: SELL YOUR NOTES ---
                    _SectionHeader(
                      title: "Monetize Notes",
                      subtitle: "Share your knowledge and earn money",
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    _MonetizePhotoSection(isLight: isLight),

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

/// Horizontal Photo List for Departments
class _DepartmentPhotoSection extends StatelessWidget {
  final bool isLight;

  const _DepartmentPhotoSection({required this.isLight});

  @override
  Widget build(BuildContext context) {
    final departments = [
      {
        "title": "Computer Science",
        "notes": "320+ Notes",
        "img":
            "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&q=80",
        "color": Colors.indigo
      },
      {
        "title": "Electronics & Comm",
        "notes": "210+ Notes",
        "img":
            "https://images.unsplash.com/photo-1518770660439-4636190af475?w=500&q=80",
        "color": Colors.blue
      },
      {
        "title": "Mechanical Eng",
        "notes": "180+ Notes",
        "img":
            "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500&q=80",
        "color": Colors.teal
      },
      {
        "title": "Civil Engineering",
        "notes": "150+ Notes",
        "img":
            "https://images.unsplash.com/photo-1541888946425-d0fbb186a5b3?w=500&q=80",
        "color": Colors.orange
      },
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final item = departments[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: NetworkImage(item["img"] as String),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item["notes"] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dynamic Horizontal Photo List for Handwritten Notes via Firebase (CLICKABLE TO BUY PAGE)
class _HandwrittenNotesPhotoSection extends StatelessWidget {
  final bool isLight;

  const _HandwrittenNotesPhotoSection({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.hasData && snapshot.data!.docs.isNotEmpty
            ? snapshot.data!.docs
            : [];

        if (docs.isEmpty) {
          return SizedBox(
            height: 140,
            child: Center(
              child: Text(
                "No notes uploaded yet.",
                style: TextStyle(
                    fontSize: 10,
                    color:
                        isLight ? Colors.grey.shade600 : Colors.grey.shade400),
              ),
            ),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final item = doc.data() as Map<String, dynamic>;
              final String docId = doc.id;
              final String title =
                  item["courseName"] ?? item["title"] ?? "Study Note";
              final String author = item["author"] != null
                  ? "By ${item['author']}"
                  : "By Verified Student";
              final String rating = "${item['rating'] ?? '4.9'} ★";
              final String img = item["img"] ??
                  item["imageUrl"] ??
                  "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=500&q=80";
              final String department = item["department"] ?? "General";
              final bool isFree = item["isFree"] == true;
              final String price =
                  isFree ? "Free" : "₹${item['price']?.toString() ?? '49'}";

              return GestureDetector(
                onTap: () {
                  Get.to(() => NoteBuyPage(
                        docId: docId,
                        title: title,
                        author: author,
                        department: department,
                        price: price,
                        isFree: isFree,
                        rating: rating,
                        imageUrl: img,
                        fileName: item["fileName"] ?? "Note_Document.pdf",
                      ));
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isLight ? Colors.white : const Color(0xFF1E293B),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: Image.network(
                          img,
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 80,
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            child: const Icon(Icons.note_rounded,
                                color: Color(0xFF6366F1)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isLight
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  rating,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              author,
                              style: TextStyle(
                                fontSize: 8,
                                color: isLight
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// ============================================================================
/// BUY / NOTE DETAILS PAGE (MATCHING APP UI DESIGN & SCHEME)
/// ============================================================================
class NoteBuyPage extends StatelessWidget {
  final String docId;
  final String title;
  final String author;
  final String department;
  final String price;
  final bool isFree;
  final String rating;
  final String imageUrl;
  final String fileName;

  const NoteBuyPage({
    super.key,
    required this.docId,
    required this.title,
    required this.author,
    required this.department,
    required this.price,
    required this.isFree,
    required this.rating,
    required this.imageUrl,
    required this.fileName,
  });

  Future<void> _handlePurchase(BuildContext context) async {
    try {
      // Record purchase in Firestore
      await FirebaseFirestore.instance.collection('bought_notes').add({
        'noteId': docId,
        'title': title,
        'department': department,
        'seller': author,
        'price': price,
        'isFree': isFree,
        'size': '12.4 MB',
        'date': 'Today',
        'boughtAt': FieldValue.serverTimestamp(),
      });

      // Add corresponding alert notification
      await FirebaseFirestore.instance.collection('note_alerts').add({
        'title': 'New Note Downloaded',
        'message': 'You accessed $title successfully.',
        'time': 'Just now',
        'type': 'download',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Purchase Successful! 🎉",
        "Note added to My Purchased Notes.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );

      Get.off(() => const NoteSwapNotificationScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to complete transaction: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LightModeController lightModeController = Get.find();

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
            "Note Details",
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. NOTE HERO COVER IMAGE
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: brandPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        department,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. MAIN DETAILS CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandPrimary.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rating,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      author,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // File Meta Info
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf_rounded,
                            size: 16, color: brandPrimary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            fileName,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textPrimary),
                          ),
                        ),
                        Text(
                          "PDF • 12.4 MB",
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. INCLUDED FEATURES & VERIFICATION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isLight
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's inside this Note:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FeatureTile(
                      icon: Icons.check_circle_rounded,
                      text: "Verified exam-oriented handwritten content",
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 6),
                    _FeatureTile(
                      icon: Icons.check_circle_rounded,
                      text: "High-resolution full color PDF document",
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 6),
                    _FeatureTile(
                      icon: Icons.check_circle_rounded,
                      text: "Instant download and lifetime access",
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. BUY / DOWNLOAD ACTION CONTAINER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandPrimary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Price",
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color:
                                isFree ? const Color(0xFF10B981) : brandPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _handlePurchase(context),
                      icon: Icon(
                          isFree
                              ? Icons.download_rounded
                              : Icons.shopping_cart_rounded,
                          size: 16,
                          color: Colors.white),
                      label: Text(
                        isFree ? "Download Note" : "Buy & Download",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFree ? const Color(0xFF10B981) : brandPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textSecondary;

  const _FeatureTile({
    required this.icon,
    required this.text,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ),
      ],
    );
  }
}

class _MonetizePhotoSection extends StatelessWidget {
  final bool isLight;

  const _MonetizePhotoSection({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: const DecorationImage(
          image: NetworkImage(
              "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&q=80"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.85),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "EARN REWARDS",
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Upload Notes & Get Paid",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              "Turn your class handwritten notes into extra earnings.",
              style:
                  TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
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
            onTap: () => Get.to(() => const NoteSwapSearchScreen()),
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
