import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'group_profile.dart';

class Contact {
  final String id;
  final String name;
  final String username;
  final String initials;
  final String? profileImage;

  const Contact({
    required this.id,
    required this.name,
    required this.username,
    required this.initials,
    this.profileImage,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final String name = data['name'] ?? 'Unknown';

    final String initials = name.isNotEmpty
        ? name
            .trim()
            .split(' ')
            .map((l) => l.isNotEmpty ? l[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '??';

    return Contact(
      id: doc.id,
      name: name,
      username: data['username'] ?? '',
      initials: initials.isEmpty ? '??' : initials,
      profileImage: data['profileImage'] ?? data['photoUrl'],
    );
  }
}

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _selectedContactIds = {};
  String _searchQuery = "";
  bool _isLoading = false;

  // Modernized design tokens
  static const Color primaryAccent = Color(0xFF6366F1); // Modern Indigo
  static const Color backgroundCard = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createGroupInFirebase() async {
    final groupName = _nameController.text.trim();
    final groupDescription = _descriptionController.text.trim();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (groupName.isEmpty) {
      _showSnackBar('Please name your group');
      return;
    }

    if (_selectedContactIds.isEmpty) {
      _showSnackBar('Select at least one group member');
      return;
    }

    if (currentUserId == null) {
      _showSnackBar('User session expired');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();

      final Set<String> completeMemberIds = Set.from(_selectedContactIds)
        ..add(currentUserId);
      final int memberCount = completeMemberIds.length;
      const int maxMembers = 50;

      final DocumentReference chatGroupDocRef =
          firestore.collection('group_chats').doc();

      final Map<String, dynamic> chatGroupData = {
        'name': groupName,
        'description': groupDescription,
        'collegeId': '',
        'memberCount': memberCount,
        'maxMembers': maxMembers,
        'remainingSeats': maxMembers - memberCount,
        'createdBy': currentUserId,
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'members': completeMemberIds.toList(),
      };

      batch.set(chatGroupDocRef, chatGroupData);
      await batch.commit();

      if (!mounted) return;
      _showSnackBar('Group created successfully ✨');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GroupDetailsPage(groupId: chatGroupDocRef.id),
        ),
      );
    } catch (e) {
      _showSnackBar('Failed to create group: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: const Icon(Icons.close, color: textDark, size: 24),
            // Cleanly dismisses the overlay/screen to return to the last page
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Create Hub',
          style: TextStyle(
              color: textDark, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading potential members.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryAccent));
          }

          final List<Contact> allContacts = snapshot.data!.docs
              .map((doc) => Contact.fromFirestore(doc))
              .toList();

          final List<Contact> selectedContacts = allContacts
              .where((c) => _selectedContactIds.contains(c.id))
              .toList();

          final List<Contact> filteredContacts = allContacts.where((contact) {
            final query = _searchQuery.toLowerCase();
            return contact.name.toLowerCase().contains(query) ||
                contact.username.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20.0),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundCard,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _AvatarUploader(),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _nameController,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: textDark),
                                      decoration: const InputDecoration(
                                        hintText: 'Name your group...',
                                        hintStyle:
                                            TextStyle(color: Colors.black38),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                    const Divider(
                                        color: Colors.black12, height: 16),
                                    TextField(
                                      controller: _descriptionController,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontSize: 14, color: textMuted),
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Add an optional description or purpose...',
                                        hintStyle:
                                            TextStyle(color: Colors.black26),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (selectedContacts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 4),
                              child: Text(
                                'MEMBERS (${selectedContacts.length})',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: textMuted,
                                    letterSpacing: 1.2),
                              ),
                            ),
                            _SelectedContactsTray(
                              selectedContacts: selectedContacts,
                              onRemove: (id) => setState(
                                  () => _selectedContactIds.remove(id)),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      toolbarHeight: 60,
                      titleSpacing: 20,
                      title: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Invite teammates...',
                          hintStyle:
                              const TextStyle(color: textMuted, fontSize: 14),
                          prefixIcon: const Icon(Icons.search,
                              color: textMuted, size: 20),
                          filled: true,
                          fillColor: backgroundCard,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final contact = filteredContacts[index];
                            final isSelected =
                                _selectedContactIds.contains(contact.id);
                            return _ContactRowTile(
                              contact: contact,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedContactIds.remove(contact.id);
                                  } else {
                                    _selectedContactIds.add(contact.id);
                                  }
                                });
                              },
                            );
                          },
                          childCount: filteredContacts.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, -4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createGroupInFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Launch Group',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AvatarUploader extends StatelessWidget {
  const _AvatarUploader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xffE4E5EF), width: 1.5),
          ),
          child: const Icon(Icons.add_photo_alternate_outlined,
              size: 28, color: _NewGroupScreenState.primaryAccent),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: _NewGroupScreenState.primaryAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SelectedContactsTray extends StatelessWidget {
  final List<Contact> selectedContacts;
  final ValueChanged<String> onRemove;

  const _SelectedContactsTray({
    required this.selectedContacts,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: selectedContacts.length,
        itemBuilder: (context, index) {
          final contact = selectedContacts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFEEF2FF),
                        backgroundImage: contact.profileImage != null &&
                                contact.profileImage!.isNotEmpty
                            ? NetworkImage(contact.profileImage!)
                            : null,
                        child: contact.profileImage == null ||
                                contact.profileImage!.isEmpty
                            ? Text(
                                contact.initials,
                                style: const TextStyle(
                                    color: _NewGroupScreenState.primaryAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.name.split(' ')[0],
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _NewGroupScreenState.textDark),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => onRemove(contact.id),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Color(0xFFEF4444), shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          size: 10, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactRowTile extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContactRowTile({
    required this.contact,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFF3F4F6),
        backgroundImage:
            contact.profileImage != null && contact.profileImage!.isNotEmpty
                ? NetworkImage(contact.profileImage!)
                : null,
        child: contact.profileImage == null || contact.profileImage!.isEmpty
            ? Text(
                contact.initials,
                style: const TextStyle(
                    color: _NewGroupScreenState.textMuted,
                    fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        contact.name,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _NewGroupScreenState.textDark,
            fontSize: 15),
      ),
      subtitle: Text(
        '@${contact.username}',
        style: const TextStyle(
            color: _NewGroupScreenState.textMuted, fontSize: 13),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? _NewGroupScreenState.primaryAccent : Colors.white,
          border: Border.all(
            color: isSelected
                ? _NewGroupScreenState.primaryAccent
                : const Color(0xFFD1D5DB),
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}
