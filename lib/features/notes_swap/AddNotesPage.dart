import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Views/Notification.dart';
import 'package:noteswap/features/notes_swap/searchScreen.dart';

import '../../Constents/AppConstents.dart';
import '../../Widgets/Buttons/BackWidgets.dart';
import 'FeedScreen.dart';
import 'noti.dart';

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final LightModeController lightModeController =
      Get.put(LightModeController());

  // Form Controllers & State Flags
  final _formKey = GlobalKey<FormState>();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedDepartment;
  bool isPublic = true;
  bool isFree = false;
  bool isUploading = false;
  String? uploadedFileName;

  void _pickFile() {
    // Simulate File Picker Selection
    setState(() {
      uploadedFileName = "CS_Data_Structures_Notes_2026.pdf";
    });
    Get.snackbar(
      "File Selected",
      "CS_Data_Structures_Notes_2026.pdf ready for upload",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _submitNotes() async {
    if (_formKey.currentState!.validate()) {
      if (uploadedFileName == null) {
        Get.snackbar(
          "File Required",
          "Please upload your notes PDF or document.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      setState(() => isUploading = true);

      try {
        await FirebaseFirestore.instance.collection('notes').add({
          'department': selectedDepartment,
          'courseName': courseNameController.text.trim(),
          'fileName': uploadedFileName,
          'price': isFree ? 0 : (double.tryParse(priceController.text) ?? 0),
          'isFree': isFree,
          'isPublic': isPublic,
          'author': 'Student User',
          'rating': "5.0",
          'downloads': "0",
          'createdAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          "Success! 🎉",
          "Your notes have been uploaded successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );

        // Reset form
        courseNameController.clear();
        priceController.clear();
        setState(() {
          uploadedFileName = null;
          selectedDepartment = null;
        });
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to upload note: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

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
      final inputBg =
          isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
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
            "Upload Notes",
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
            // 1. TOP HEADER NAVIGATION BAR
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

            // 2. FORM BODY
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- DEPARTMENT NAME DROPDOWN (DYNAMIC FROM FIREBASE) ---
                      _LabelText("Department Name", textPrimary),
                      const SizedBox(height: 6),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('departments')
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<String> departments =
                              snapshot.hasData && snapshot.data!.docs.isNotEmpty
                                  ? snapshot.data!.docs
                                      .map((doc) => doc['name'].toString())
                                      .toList()
                                  : [
                                      'Computer Science',
                                      'Electronics & Comm',
                                      'Mechanical Eng',
                                      'Civil Engineering',
                                      'Chemical Eng',
                                      'Electrical Eng',
                                    ];

                          return DropdownButtonFormField<String>(
                            value: selectedDepartment,
                            dropdownColor: cardColor,
                            style: TextStyle(fontSize: 12, color: textPrimary),
                            decoration: _inputDecoration(
                              hint: "Select Department",
                              icon: Icons.domain_rounded,
                              fillColor: inputBg,
                              isLight: isLight,
                            ),
                            items: departments
                                .map((dept) => DropdownMenuItem(
                                      value: dept,
                                      child: Text(dept),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedDepartment = val),
                            validator: (val) => val == null
                                ? "Please select a department"
                                : null,
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // --- COURSE NAME INPUT ---
                      _LabelText("Course / Subject Name", textPrimary),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: courseNameController,
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        decoration: _inputDecoration(
                          hint: "e.g. Data Structures, Thermodynamics",
                          icon: Icons.menu_book_rounded,
                          fillColor: inputBg,
                          isLight: isLight,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "Please enter course name"
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // --- FILE UPLOAD CONTAINER ---
                      _LabelText("Upload File (PDF / Doc)", textPrimary),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: uploadedFileName != null
                                  ? const Color(0xFF10B981)
                                  : brandPrimary.withOpacity(0.3),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: uploadedFileName != null
                                    ? const Color(0xFF10B981).withOpacity(0.12)
                                    : brandPrimary.withOpacity(0.12),
                                child: Icon(
                                  uploadedFileName != null
                                      ? Icons.check_circle_rounded
                                      : Icons.cloud_upload_rounded,
                                  color: uploadedFileName != null
                                      ? const Color(0xFF10B981)
                                      : brandPrimary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uploadedFileName ??
                                    "Tap to choose a file or PDF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: uploadedFileName != null
                                      ? const Color(0xFF10B981)
                                      : textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Supports PDF, DOCX, TXT up to 25MB",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- PRICE (RUPEES) SECTION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _LabelText("Price (Rupees ₹)", textPrimary),
                          Row(
                            children: [
                              Text(
                                "Free Note",
                                style: TextStyle(
                                    fontSize: 10, color: textSecondary),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                height: 24,
                                width: 50,
                                child: Switch(
                                  value: isFree,
                                  activeColor: brandPrimary,
                                  onChanged: (val) {
                                    setState(() {
                                      isFree = val;
                                      if (isFree) priceController.clear();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: priceController,
                        enabled: !isFree,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        decoration: _inputDecoration(
                          hint: isFree ? "Marked as Free" : "e.g. 49",
                          icon: Icons.currency_rupee_rounded,
                          fillColor: isFree
                              ? (isLight
                                  ? Colors.grey.shade200
                                  : Colors.white10)
                              : inputBg,
                          isLight: isLight,
                        ),
                        validator: (val) {
                          if (!isFree && (val == null || val.trim().isEmpty)) {
                            return "Please set a price or mark as free";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // --- VISIBILITY (PUBLIC / PRIVATE) ---
                      _LabelText("Visibility Settings", textPrimary),
                      const SizedBox(height: 6),
                      Container(
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
                                onTap: () => setState(() => isPublic = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isPublic
                                        ? brandPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.public_rounded,
                                        size: 14,
                                        color: isPublic
                                            ? Colors.white
                                            : textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Public",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isPublic
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
                                onTap: () => setState(() => isPublic = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isPublic
                                        ? brandPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock_outline_rounded,
                                        size: 14,
                                        color: !isPublic
                                            ? Colors.white
                                            : textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Private",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: !isPublic
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

                      const SizedBox(height: 24),

                      // --- SUBMIT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isUploading ? null : _submitNotes,
                          child: isUploading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "Publish Notes",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color fillColor,
    required bool isLight,
  }) {
    const brandPrimary = Color(0xFF6366F1);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 11,
          color: isLight ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: brandPrimary, size: 16),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: brandPrimary, width: 1.5),
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String label;
  final Color textColor;

  const _LabelText(this.label, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: textColor,
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
            onTap: () => Get.off(() => NoteSwapSearchScreen()),
          ),
          _NavChip(
            icon: Icons.note_add_rounded,
            label: 'Add Notes',
            isActive: true,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () {},
          ),
          _NavChip(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            isActive: false,
            activeColor: activeColor,
            bgColor: cardBg,
            textColor: textColor,
            onTap: () => Get.to(() => NoteSwapNotificationScreen()),
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
