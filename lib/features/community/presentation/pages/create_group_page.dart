import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/group.dart';
import '../../domain/repos/group_repo.dart';

// --- Constants & Styling ---
const List<String> categories = [
  'Education',
  'Technology',
  'Gaming',
  'Sports',
  'Programming',
  'Business',
  'Design'
];

const List<String> defaultRules = [
  'Be respectful and kind to everyone',
  'No spam and self promotion',
  'Help others and grow together',
];

const Color _primaryPurple = Color(0xFF6338F6);
const Color _lightPurpleBg = Color(0xFFF7F5FF);
const Color _primaryText = Color(0xFF222B45);
const Color _secondaryText = Color(0xFF8F9BB3);
const Color _borderColor = Color(0xFFE4E9F2);

// --- Main Screen ---
class CreateGroupPage extends StatefulWidget {
  final String collegeId;
  const CreateGroupPage({super.key, required this.collegeId});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedCategory = 'Education';
  bool _isPublic = true;
  final List<String> _rules = List.from(defaultRules);
  bool _bannerUploaded = false;
  bool _logoUploaded = false;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _showSnackBar("Please select a category for your community");
      return;
    }

    setState(() => isLoading = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      await sl<GroupRepo>().createGroup(
        Group(
          id: '',
          name: _nameController.text.trim(),
          collegeId: widget.collegeId,
          description: _descController.text.trim(),
          category: _selectedCategory!, // <--- PASS CATEGORY
          isPublic: _isPublic, // <--- PASS PRIVACY SETTING
          rules: _rules, // <--- PASS RULES LIST
          memberCount: 0,
          maxMembers: 50,
          remainingSeats: 50,
          createdBy: currentUser.uid,
          imageUrl: '',
          createdAt: Timestamp.now(),
        ),
      );

      if (!mounted) return;
      _showSnackBar("Community created successfully! 🎉");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  void _addNewRule() {
    final ruleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Rule", style: TextStyle(fontSize: 18)),
        content: TextField(
          controller: ruleController,
          decoration: const InputDecoration(hintText: "Enter rule..."),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (ruleController.text.trim().isNotEmpty) {
                setState(() => _rules.add(ruleController.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF222B45), size: 24),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create community',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Build space for like minded people',
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        const _FormSectionTitle('Community name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          maxLength: 30,
                          onChanged: (_) => setState(() {}),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Enter community name"
                              : null,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _primaryText),
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          decoration: _inputDecoration(
                            prefixIcon: const Icon(Icons.group_outlined,
                                color: _primaryPurple, size: 20),
                            suffix: Text(
                              '${_nameController.text.length}/30',
                              style: const TextStyle(
                                  color: _primaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description Field
                        const _FormSectionTitle('Short Description'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descController,
                          minLines: 3,
                          maxLines: 4,
                          maxLength: 100,
                          onChanged: (_) => setState(() {}),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Write a short description"
                              : null,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _primaryText,
                              height: 1.3),
                          buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '$currentLength/$maxLength',
                                style: const TextStyle(
                                    color: _primaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 16),

                        // Banner Upload
                        const _FormSectionTitle('Banner Image'),
                        const SizedBox(height: 8),
                        _UploadBox(
                          height: 90,
                          title: 'Upload Banner',
                          subtitle: 'recommended size: 1200x400',
                          icon: Icons.landscape_outlined,
                          useDefaultContainer: !_bannerUploaded,
                          bannerIcon: Icons.code_rounded,
                          onTap: () => setState(
                              () => _bannerUploaded = !_bannerUploaded),
                        ),
                        const SizedBox(height: 16),

                        // Logo Upload
                        const _FormSectionTitle('Community Logo'),
                        const SizedBox(height: 8),
                        _UploadBox(
                          height: 85,
                          width: 85,
                          title: 'Upload logo',
                          subtitle: 'recommended size: 512x512',
                          showSubtitleBelow: true,
                          icon: Icons.camera_alt_outlined,
                          useDefaultContainer: !_logoUploaded,
                          bannerIcon: Icons.group_outlined,
                          onTap: () =>
                              setState(() => _logoUploaded = !_logoUploaded),
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        const _FormSectionTitle('Category'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: _primaryPurple),
                          decoration: _inputDecoration(
                            prefixIcon: const Icon(
                                Icons.workspace_premium_outlined,
                                color: _primaryText,
                                size: 22),
                          ),
                          items: categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _primaryText,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        // Privacy Options
                        const _FormSectionTitle('Privacy settings'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _PrivacyCard(
                                icon: Icons.language,
                                title: 'Public',
                                subtitle: 'Anyone can discover\nand join',
                                isSelected: _isPublic,
                                onTap: () => setState(() => _isPublic = true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PrivacyCard(
                                icon: Icons.lock_outline,
                                title: 'Private',
                                subtitle: 'Only people with\ninvite can join',
                                isSelected: !_isPublic,
                                onTap: () => setState(() => _isPublic = false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Community Rules
                        _RulesCard(rules: _rules, onAddRule: _addNewRule),
                        const SizedBox(height: 24),

                        // Submit Button
                        Center(
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: 140,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: createGroup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor:
                                          _primaryPurple.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'create community',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? prefixIcon, Widget? suffix}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [suffix],
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryPurple, width: 1.5),
      ),
    );
  }
}

// --- Helper UI Components ---

class _FormSectionTitle extends StatelessWidget {
  final String title;
  const _FormSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _primaryText,
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final double height;
  final double? width;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool showSubtitleBelow;
  final bool useDefaultContainer;
  final IconData bannerIcon;

  const _UploadBox({
    required this.height,
    this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageUrl,
    required this.onTap,
    this.showSubtitleBelow = false,
    this.useDefaultContainer = false,
    this.bannerIcon = Icons.code_rounded,
  });

  @override
  Widget build(BuildContext context) {
    Widget boxContent;

    if (useDefaultContainer) {
      boxContent = Container(
        height: height,
        width: width ?? double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color(0xFF0F172A),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Center(
            child: Icon(
              bannerIcon,
              color: Colors.orange,
              size: 28,
            ),
          ),
        ),
      );
    } else {
      boxContent = CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFF9D84FF),
          strokeWidth: 1.5,
          dashWidth: 5,
          dashSpace: 4,
        ),
        child: Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: _lightPurpleBg,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      );
    }

    if (showSubtitleBelow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(onTap: onTap, child: boxContent),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: _secondaryText),
          ),
        ],
      );
    }

    return GestureDetector(onTap: onTap, child: boxContent);
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _primaryPurple, size: 28),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _primaryPurple,
          ),
        ),
        if (!showSubtitleBelow)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: _secondaryText),
          ),
      ],
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _lightPurpleBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primaryPurple : _borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _primaryText, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: _secondaryText,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final List<String> rules;
  final VoidCallback onAddRule;

  const _RulesCard({required this.rules, required this.onAddRule});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Community Rules',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _primaryText,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle_outline,
                        color: _primaryPurple, size: 16),
                  ],
                ),
                const SizedBox(height: 10),
                ...rules.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key + 1}. ',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _primaryText,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const Divider(height: 1, color: _borderColor),
          InkWell(
            onTap: onAddRule,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.add, color: _primaryPurple, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'add rule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter for Dashed Border ---
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );

    final Path path = Path()..addRRect(rrect);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        canvas.drawPath(
          metric.extractPath(distance, distance + length),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
