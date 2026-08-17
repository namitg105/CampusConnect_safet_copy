import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/NotificationController.dart';
import 'package:noteswap/features/events/notifications/notifications_screen.dart';

import 'note_data.dart';
import 'SearchResultsScreen.dart';
import 'NoteDetailsScreen.dart';
import 'MyNotesScreen.dart';
import 'AllNotesScreen.dart';
import 'noteswap_controller.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  static const Color _background = Color(0xFFF6F5FB);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textMuted = Color(0xFF8B879E);
  static const Color _cardColor = Colors.white;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(NoteswapController(), permanent: true).loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NoteswapController>();
    return Scaffold(
      backgroundColor: NotesScreen._background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Obx(() {
              final featured = ctrl.featuredNotes;
              final recent = ctrl.recentNotes;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 16),
                  const _Greeting(),
                  const SizedBox(height: 18),
                  const _SearchBar(),
                  const SizedBox(height: 24),
                  if (ctrl.homeError.value != null)
                    _HomeErrorBanner(
                      onRetry: () => ctrl.loadHome(),
                    ),
                  if (ctrl.homeError.value != null) const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Featured Notes',
                    onViewAll: featured.isEmpty
                        ? null
                        : () => _openAllNotes(
                            context,
                            'Featured Notes',
                            featured,
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (ctrl.homeLoading.value)
                    const _NotesLoadingPlaceholder()
                  else if (featured.isEmpty)
                    const _EmptyNotesCard()
                  else
                    _FeaturedRow(notes: featured),
                  const SizedBox(height: 24),
                  const _MyNotesBanner(),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Recently Added',
                    onViewAll: recent.isEmpty
                        ? null
                        : () => _openAllNotes(
                            context,
                            'Recently Added',
                            recent,
                          ),
                  ),
                  const SizedBox(height: 10),
                  if (ctrl.homeLoading.value)
                    const _NotesLoadingPlaceholder()
                  else if (recent.isEmpty)
                    const _EmptyNotesCard()
                  else
                    _RecentlyAddedCard(notes: recent),
                  const SizedBox(height: 30),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

void _openAllNotes(BuildContext context, String title, List<Note> notes) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AllNotesScreen(title: title, notes: notes),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: NotesScreen._accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'uniConnect',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: NotesScreen._textDark,
                  ),
                ),
              ],
            ),
          ),
          const _NotificationButton(),
          const SizedBox(width: 12),
          const _Avatar(),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    final NotificationController notifCtrl =
        Get.find<NotificationController>();
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NotesScreen._cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.notifications_none,
                color: NotesScreen._textDark,
                size: 22,
              ),
              onPressed: () => Get.to(() => const NotificationsScreen()),
            ),
          ),
          if (notifCtrl.unreadCount.value > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: NotesScreen._cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: NotesScreen._accent,
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: NotesScreen._textMuted,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Explore notes & uploads',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: NotesScreen._textDark,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SearchResultsScreen(),
          ),
        );
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: NotesScreen._cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IgnorePointer(
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.search,
                color: NotesScreen._textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: TextField(
                  readOnly: true,
                  showCursor: false,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: NotesScreen._textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: NotesScreen._accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NotesScreen._textDark,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NotesScreen._accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesLoadingPlaceholder extends StatelessWidget {
  const _NotesLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: NotesScreen._cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: NotesScreen._accent,
          strokeWidth: 2.4,
        ),
      ),
    );
  }
}

class _HomeErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: NotesScreen._cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NotesScreen._accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: NotesScreen._textMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Could not load notes. Check your connection and retry.',
              style: TextStyle(
                fontSize: 13,
                color: NotesScreen._textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: NotesScreen._accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotesCard extends StatelessWidget {
  const _EmptyNotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: NotesScreen._cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            color: NotesScreen._accent,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: NotesScreen._textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Be the first to share your notes',
            style: TextStyle(
              fontSize: 12,
              color: NotesScreen._textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  final List<Note> notes;

  const _FeaturedRow({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(child: _FeaturedCard(note: notes[0])),
        if (notes.length > 1) ...[
          const SizedBox(width: 12),
          Expanded(child: _FeaturedCard(note: notes[1])),
        ],
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Note note;

  const _FeaturedCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteDetailsScreen(note: note),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NotesScreen._cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: note.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.menu_book,
              color: note.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NotesScreen._textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note.subject,
            style: const TextStyle(
              fontSize: 11,
              color: NotesScreen._textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.uploadTime,
                style: const TextStyle(
                  fontSize: 10,
                  color: NotesScreen._textMuted,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.download_outlined,
                    color: NotesScreen._textMuted,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${note.downloads}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: NotesScreen._textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _MyNotesBanner extends StatelessWidget {
  const _MyNotesBanner();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double imageWidth =
        (screenWidth * 0.42).clamp(120.0, 180.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
      decoration: BoxDecoration(
        color: NotesScreen._cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              widthFactor: 1,
              child: Image.asset(
                'assets/chat_assets/person-upload-notes.png',
                width: imageWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Go to your uploads and get some notes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NotesScreen._textDark,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyNotesScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: NotesScreen._accent,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Text(
                      'my notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyAddedCard extends StatelessWidget {
  final List<Note> notes;

  const _RecentlyAddedCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: NotesScreen._cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New this week',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NotesScreen._textDark,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: NotesScreen._textMuted,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UserTile(note: notes[0]),
          if (notes.length > 1) ...[
            const _SubtleDivider(),
            _UserTile(note: notes[1]),
          ],
          if (notes.length > 2) ...[
            const _SubtleDivider(),
            _UserTile(note: notes[2]),
          ],
        ],
      ),
    );
  }
}

class _SubtleDivider extends StatelessWidget {
  const _SubtleDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: Color(0xFFEFEEF5),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Note note;

  const _UserTile({required this.note});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteDetailsScreen(note: note),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: note.accent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              note.author.isNotEmpty ? note.author[0] : '?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: note.accent,
              ),
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
                  color: NotesScreen._textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${note.author} | ${note.subject}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: NotesScreen._textMuted,
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
              children: [
                const Icon(
                  Icons.download_outlined,
                  color: NotesScreen._accent,
                  size: 15,
                ),
                const SizedBox(width: 2),
                Text(
                  '${note.downloads}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NotesScreen._accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              note.uploadTime,
              style: const TextStyle(
                fontSize: 10,
                color: NotesScreen._textMuted,
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}
