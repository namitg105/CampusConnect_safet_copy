import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Search screen for text messages within a group chat.
///
/// Firestore doesn't support native full-text search, so this fetches the
/// most recent text messages once and filters them client-side as the user
/// types. That's fine for small/medium groups; for very large chat
/// histories you'd want a dedicated search index (e.g. Algolia or
/// Typesense) instead of raising the `limit` below.
///
/// Assumes messages live at `groups/{groupId}/messages` with fields
/// `type` ('text' for plain messages), `text`, and `timestamp`.
class SearchMessagesPage extends StatefulWidget {
  final String groupId;
  const SearchMessagesPage({super.key, required this.groupId});

  @override
  State<SearchMessagesPage> createState() => _SearchMessagesPageState();
}

class _SearchMessagesPageState extends State<SearchMessagesPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<QueryDocumentSnapshot> _allMessages = [];
  List<QueryDocumentSnapshot> _results = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      // 🧪 Temporary relaxed query to see what's actually in your database
      final snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .limit(10) // Just fetch the first 10 items regardless of type/time
          .get();

      print("--- DEBUG DATA START ---");
      print("Target Group ID: ${widget.groupId}");
      print("Documents Found: ${snapshot.docs.length}");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("Doc ID: ${doc.id} -> Data: $data");
        print(
            "Has type='text'? -> ${data['type'] == 'text'} (Actual: ${data['type']})");
        print(
            "Has timestamp? -> ${data.containsKey('timestamp')} (Actual: ${data['timestamp']})");
      }
      print("--- DEBUG DATA END ---");

      if (mounted) {
        setState(() {
          _allMessages = snapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Firestore Query Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() {
        _results = _allMessages.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final text = (data['text'] ?? '').toString().toLowerCase();
          return text.contains(q);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp ts) {
    final date = ts.toDate();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onQueryChanged,
          decoration: const InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)));
    }
    if (_hasError) {
      return const Center(child: Text('Failed to load messages.'));
    }
    if (_controller.text.trim().isEmpty) {
      return const Center(
        child: Text('Type to search messages in this group.',
            style: TextStyle(color: Color(0xff8B899F))),
      );
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No messages found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final data = _results[index].data() as Map<String, dynamic>;
        final text = (data['text'] ?? '').toString();
        final timestamp = data['timestamp'] as Timestamp?;
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(Icons.chat_bubble_outline, color: Color(0xFF6366F1)),
          ),
          title: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle:
              timestamp != null ? Text(_formatTimestamp(timestamp)) : null,
        );
      },
    );
  }
}
