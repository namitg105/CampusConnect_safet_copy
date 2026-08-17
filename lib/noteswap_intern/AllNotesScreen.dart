import 'package:flutter/material.dart';

import 'note_data.dart';
import 'NoteDetailsScreen.dart';

class AllNotesScreen extends StatelessWidget {
  final String title;
  final List<Note> notes;

  const AllNotesScreen({
    super.key,
    required this.title,
    required this.notes,
  });

  static const Color _background = Color(0xFFF7F6FC);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF1F2747);
  static const Color _textMuted = Color(0xFF8B879E);
  static const Color _shadowColor = Color(0x0A000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(title: title),
                const SizedBox(height: 24),
                for (var i = 0; i < notes.length; i++) ...[
                  _NoteCard(note: notes[i]),
                  if (i != notes.length - 1) const SizedBox(height: 14),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: AllNotesScreen._shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                color: AllNotesScreen._textDark,
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AllNotesScreen._textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({required this.note});

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
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AllNotesScreen._shadowColor,
              blurRadius: 20,
              spreadRadius: 0,
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
                      color: AllNotesScreen._textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${note.subject} • ${note.uploadTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AllNotesScreen._textMuted,
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
                      color: AllNotesScreen._accent,
                      size: 15,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${note.downloads}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AllNotesScreen._accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AllNotesScreen._textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
