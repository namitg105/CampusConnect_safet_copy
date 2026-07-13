import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';

import '../../../community/presentation/cubits/group_cubit.dart';
import '../../../community/presentation/pages/groups_page.dart';
import 'group_profile.dart';

/// Models the domain entity for individual network contacts.
class Contact {
  final String id;
  final String name;
  final String username;
  final String initials;
  final Color avatarColor;

  const Contact({
    required this.id,
    required this.name,
    required this.username,
    required this.initials,
    required this.avatarColor,
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
      avatarColor: Colors.indigo.shade100,
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

  static const Color primaryPurple = Color(0xff6C63FF);
  static const Color borderColor = Color(0xffE4E5EF);

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
      _showSnackBar('Please enter a group name');
      return;
    }

    if (_selectedContactIds.isEmpty) {
      _showSnackBar('Please select at least one contact');
      return;
    }

    if (currentUserId == null) {
      _showSnackBar('User not authenticated');
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
      _showSnackBar('Group chat created successfully!');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GroupDetailsPage(groupId: chatGroupDocRef.id),
        ),
      );
    } catch (e) {
      _showSnackBar('Error creating group chat: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: Colors.black),
              onPressed: () {
                final groupCubit = BlocProvider.of<GroupCubit>(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: groupCubit,
                      child: MainPage(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        title: const Text(
          'New group',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: primaryPurple),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _createGroupInFirebase,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        color: primaryPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: Colors.grey.shade100, height: 2),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Something went wrong fetching contacts.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const _GroupAvatarHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          _buildCustomTextField(
                            controller: _nameController,
                            hintText: 'Group Name',
                            centerText: true,
                          ),
                          const SizedBox(height: 12),
                          _buildCustomTextField(
                            controller: _descriptionController,
                            hintText: 'Group Description',
                            centerText: true,
                            isLight: true,
                            verticalPadding: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: borderColor),
                    _buildSectionHeader(
                        'SELECTED · ${_selectedContactIds.length}'),
                    if (selectedContacts.isNotEmpty)
                      _SelectedContactsHorizontalList(
                        selectedContacts: selectedContacts,
                        onRemove: (id) =>
                            setState(() => _selectedContactIds.remove(id)),
                      ),
                    const Divider(height: 1, color: borderColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          hintStyle: const TextStyle(color: Colors.black26),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.black26, size: 20),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: borderColor),
                    _buildSectionHeader('CONTACTS'),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final contact = filteredContacts[index];
                    final isSelected = _selectedContactIds.contains(contact.id);
                    return Column(
                      children: [
                        _ContactListTile(
                          contact: contact,
                          isSelected: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedContactIds.add(contact.id);
                              } else {
                                _selectedContactIds.remove(contact.id);
                              }
                            });
                          },
                        ),
                        if (index < filteredContacts.length - 1)
                          const Divider(height: 1, indent: 20, endIndent: 20),
                      ],
                    );
                  },
                  childCount: filteredContacts.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.grey.shade100,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xffA9AABF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    bool centerText = false,
    bool isLight = false,
    double verticalPadding = 14,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textAlign: centerText ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: isLight ? Colors.black54 : Colors.black87,
          fontWeight: isLight ? FontWeight.normal : FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              TextStyle(color: isLight ? Colors.black38 : Colors.black26),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
        ),
      ),
    );
  }
}

class _GroupAvatarHeader extends StatelessWidget {
  const _GroupAvatarHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFE8EAF6),
            child: Icon(Icons.group, size: 40, color: Colors.indigo),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xff6C63FF),
              child:
                  const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedContactsHorizontalList extends StatelessWidget {
  final List<Contact> selectedContacts;
  final ValueChanged<String> onRemove;

  const _SelectedContactsHorizontalList({
    required this.selectedContacts,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: selectedContacts.length,
        itemBuilder: (context, index) {
          final contact = selectedContacts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: contact.avatarColor,
                      child: Text(
                        contact.initials,
                        style: TextStyle(
                            color: Colors.blueGrey.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => onRemove(contact.id),
                        child: const CircleAvatar(
                          radius: 7,
                          backgroundColor: Colors.blueGrey,
                          child:
                              Icon(Icons.close, size: 10, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contact.name.split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _ContactListTile({
    required this.contact,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: contact.avatarColor,
        child: Text(
          contact.initials,
          style: TextStyle(
              color: Colors.blueGrey.shade800, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        contact.name,
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      subtitle: Text(
        contact.username,
        style: const TextStyle(color: Colors.black38, fontSize: 13),
      ),
      trailing: Transform.scale(
        scale: 1.1,
        child: Checkbox(
          value: isSelected,
          activeColor: const Color(0xFF5C6BC0),
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.black12, width: 1.5),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
