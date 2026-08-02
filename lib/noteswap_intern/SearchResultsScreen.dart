import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'note_data.dart';
import 'NoteDetailsScreen.dart';
import 'noteswap_controller.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const Color _background = Color(0xFFF8F8FC);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF20263A);
  static const Color _textMuted = Color(0xFF8B879E);
  static const Color _cardBorder = Color(0xFFE7E9F2);
  static const Color _searchBarBorder = Color(0xFFEEEEEE);

  final TextEditingController _controller = TextEditingController();
  String _query = '';
  List<Note> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    final results = await Get.find<NoteswapController>().search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: _background,
        resizeToAvoidBottomInset: true,
        extendBody: false,
        extendBodyBehindAppBar: false,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Header(),
                  const SizedBox(height: 28),
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _SearchBar(
                    controller: _controller,
                    query: _query,
                    onChanged: _onQueryChanged,
                    onClear: () {
                      _controller.clear();
                      setState(() => _query = '');
                      _search('');
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_searching && results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (results.isEmpty)
                    const Center(child: _EmptyResults())
                  else
                    for (var i = 0; i < results.length; i++) ...[
                      _SearchResultCard(note: results[i]),
                      if (i != results.length - 1) const SizedBox(height: 16),
                    ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _SearchResultsScreenState._accent,
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
              fontWeight: FontWeight.w600,
              color: _SearchResultsScreenState._accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _SearchResultsScreenState._searchBarBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search,
            color: _SearchResultsScreenState._textMuted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search notes, subjects, authors...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: _SearchResultsScreenState._textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (query.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                color: _SearchResultsScreenState._textMuted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Note note;

  const _SearchResultCard({required this.note});

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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _SearchResultsScreenState._cardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: note.accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.menu_book,
                color: note.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _SearchResultsScreenState._textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${note.author} | ${note.subject}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _SearchResultsScreenState._textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.download_outlined,
                        color: _SearchResultsScreenState._accent,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${note.downloads}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _SearchResultsScreenState._accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        note.uploadTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _SearchResultsScreenState._textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: _SearchResultsScreenState._textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            color: _SearchResultsScreenState._textMuted,
            size: 48,
          ),
          const SizedBox(height: 14),
          const Text(
            'No notes found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _SearchResultsScreenState._textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different keyword',
            style: TextStyle(
              fontSize: 13,
              color: _SearchResultsScreenState._textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
