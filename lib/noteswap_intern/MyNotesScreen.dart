import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_notes_data.dart';
import 'backend/note_models.dart';
import 'noteswap_controller.dart';

class MyNotesScreen extends StatefulWidget {
  const MyNotesScreen({super.key});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {
  static const Color _background = Color(0xFFF7F6FC);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF22263A);
  static const Color _textMuted = Color(0xFF757575);
  static const Color _shadowColor = Color(0x0D000000);

  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    Get.find<NoteswapController>().loadMyNotes(uid);
  }

  Future<void> _deleteNote(DashboardNote note) async {
    final ctrl = Get.find<NoteswapController>();
    final String id = note.id.isEmpty ? note.title : note.id;
    try {
      await ctrl.deleteNote(id);
      ctrl.myNotes.removeWhere(
        (n) => (n.id.isEmpty ? n.title : n.id) == id,
      );
      ctrl.boughtNotes.removeWhere(
        (n) => (n.id.isEmpty ? n.title : n.id) == id,
      );
    } on NoteHasBuyersException {
      Get.snackbar('buys exists at this notes', 'not allowed to delete');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NoteswapController>();

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: Obx(
          () {
            final myNotes = ctrl.myNotes;
            final boughtNotes = ctrl.boughtNotes;
            final visibleNotes = _tab == 0 ? myNotes : boughtNotes;
            final loading = ctrl.notesLoading.value && visibleNotes.isEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _NavBar(),
                    const SizedBox(height: 20),
                    const _DashboardHeader(),
                    const SizedBox(height: 24),
                    _StatsRow(notes: myNotes),
                    const SizedBox(height: 22),
                    _TabSwitcher(
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 18),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (visibleNotes.isEmpty)
                      const _EmptyState()
                    else
                      _UploadList(
                        notes: visibleNotes,
                        showDelete: _tab == 0,
                        onDelete: _deleteNote,
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const _BackButton(),
          const Expanded(child: _Logo()),
          const _Avatar(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: _MyNotesScreenState._shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.arrow_back,
          color: _MyNotesScreenState._textDark,
          size: 22,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _MyNotesScreenState._accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'uniConnect',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _MyNotesScreenState._textDark,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String photoUrl = user?.photoURL ?? '';
    final String name = user?.displayName?.trim() ?? '';
    final String email = user?.email?.trim() ?? '';

    String initials = '';
    if (name.isNotEmpty) {
      final List<String> parts = name.split(RegExp(r'\s+'));
      initials = parts.length > 1
          ? (parts[0][0] + parts[1][0]).toUpperCase()
          : parts[0][0].toUpperCase();
    } else if (email.isNotEmpty) {
      initials = email[0].toUpperCase();
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: _MyNotesScreenState._shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFEDEDFB),
        foregroundImage: photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _MyNotesScreenState._accent,
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final double imageWidth =
        (MediaQuery.sizeOf(context).width * 0.42).clamp(120.0, 170.0);
    final double imageHeight = imageWidth * (213 / 430);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Notes',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: _MyNotesScreenState._textDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your uploads and purchases',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _MyNotesScreenState._textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'assets/chat_assets/person-upload-notes.png',
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<DashboardNote> notes;

  const _StatsRow({required this.notes});

  @override
  Widget build(BuildContext context) {
    final int downloads =
        notes.fold<int>(0, (sum, n) => sum + n.buyerIds.length);
    final List<double> allRatings =
        notes.expand((n) => n.ratings).toList();
    final double avgRating = allRatings.isEmpty
        ? 0
        : allRatings.reduce((a, b) => a + b) / allRatings.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(value: '${notes.length}', label: 'Notes'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(value: '$downloads', label: 'Downloads'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: avgRating.toStringAsFixed(1),
            label: 'Avg Rating',
            prefixIcon: Icons.star,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? prefixIcon;

  const _StatCard({
    required this.value,
    required this.label,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: _MyNotesScreenState._shadowColor,
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(
                  prefixIcon,
                  color: const Color(0xFFFBBF24),
                  size: 16,
                ),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _MyNotesScreenState._textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _MyNotesScreenState._textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _TabSwitcher({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFFB),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'My Notes',
              active: index == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Bought',
              active: index == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? _MyNotesScreenState._accent
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active
                ? Colors.white
                : _MyNotesScreenState._textMuted,
          ),
        ),
      ),
    );
  }
}

class _UploadList extends StatelessWidget {
  final List<DashboardNote> notes;
  final bool showDelete;
  final ValueChanged<DashboardNote> onDelete;

  const _UploadList({
    required this.notes,
    required this.showDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final DashboardNote note in notes) ...[
          _UploadCard(
            note: note,
            showDelete: showDelete,
            onDelete: onDelete,
          ),
          if (note != notes.last) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  final DashboardNote note;
  final bool showDelete;
  final ValueChanged<DashboardNote> onDelete;

  const _UploadCard({
    required this.note,
    required this.showDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: _MyNotesScreenState._shadowColor,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: note.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book,
              color: note.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _MyNotesScreenState._textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${note.subject} • ${note.semester}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _MyNotesScreenState._textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_outlined,
                    color: _MyNotesScreenState._accent,
                    size: 15,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${note.buyerIds.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _MyNotesScreenState._accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '₹${note.price}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _MyNotesScreenState._textDark,
                ),
              ),
            ],
          ),
          if (showDelete) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onDelete(note),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: _MyNotesScreenState._shadowColor,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_off_outlined,
            color: _MyNotesScreenState._textMuted,
            size: 32,
          ),
          const SizedBox(height: 10),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _MyNotesScreenState._textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
