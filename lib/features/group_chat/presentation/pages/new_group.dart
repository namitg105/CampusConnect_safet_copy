import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../community/presentation/cubits/group_cubit.dart';
import 'group_profile.dart';
import '../../../community/presentation/pages/groups_page.dart';

class Contact {
  final String id;
  final String name;
  final String username;
  final String initials;
  final Color avatarColor;

  Contact({
    required this.id,
    required this.name,
    required this.username,
    required this.initials,
    required this.avatarColor,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String name = data['name'] ?? 'Unknown';

    String initials = name.isNotEmpty
        ? name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : '??';

    return Contact(
      id: doc.id,
      name: name,
      username: data['username'] ?? '',
      initials: initials,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedContactIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();

      // Combine chosen contacts along with the creator
      final Set<String> completeMemberIds = Set.from(_selectedContactIds)
        ..add(currentUserId);

      // Total count configurations matching Group entity properties
      final int memberCount = completeMemberIds.length;
      const int maxMembers = 50;
      final int remainingSeats = maxMembers - memberCount;

      // Single target location reference: root-level 'group_chats' collection
      DocumentReference chatGroupDocRef =
          firestore.collection('group_chats').doc();

      Map<String, dynamic> chatGroupData = {
        'name': groupName,
        'description': groupDescription,
        'collegeId': '', // Optional: bind if you collect college contexts later
        'memberCount': memberCount,
        'maxMembers': maxMembers,
        'remainingSeats': remainingSeats,
        'createdBy': currentUserId,
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'members': completeMemberIds
            .toList(), // Stores explicitly inside the document array
      };

      batch.set(chatGroupDocRef, chatGroupData);

      // Commit the write batch atomically
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group chat created successfully!')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GroupDetailsPage(groupId: chatGroupDocRef.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group chat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                        child: const GroupsPage(),
                      ),
                    ),
                  );
                }),
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
                        strokeWidth: 2,
                        color: Color(0xff6C63FF),
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _createGroupInFirebase,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        color: Color(0xff6C63FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
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

          List<Contact> allContacts = snapshot.data!.docs
              .map((doc) => Contact.fromFirestore(doc))
              .toList();

          List<Contact> selectedContacts = allContacts
              .where((c) => _selectedContactIds.contains(c.id))
              .toList();

          List<Contact> filteredContacts = allContacts.where((contact) {
            return contact.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                contact.username
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: Color(0xFFE8EAF6),
                            child: Icon(Icons.group,
                                size: 40, color: Colors.indigo),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xff6C63FF),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    const Divider(height: 1, color: Color(0xffE4E5EF)),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      color: Colors.grey.shade100,
                      child: Text(
                        'SELECTED · ${_selectedContactIds.length}',
                        style: const TextStyle(
                          color: Color(0xffA9AABF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    if (selectedContacts.isNotEmpty)
                      Container(
                        height: 90,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: selectedContacts.length,
                          itemBuilder: (context, index) {
                            final contact = selectedContacts[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                          onTap: () {
                                            setState(() {
                                              _selectedContactIds
                                                  .remove(contact.id);
                                            });
                                          },
                                          child: const CircleAvatar(
                                            radius: 7,
                                            backgroundColor: Colors.blueGrey,
                                            child: Icon(Icons.close,
                                                size: 10, color: Colors.white),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    contact.name.split(' ')[0],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const Divider(color: Color(0xffE4E5EF)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 4),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          hintStyle: const TextStyle(color: Colors.black26),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.black26, size: 20),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
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
                    const Divider(color: Color(0xffE4E5EF)),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      color: Colors.grey.shade100,
                      child: const Text(
                        'CONTACTS',
                        style: TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredContacts.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final isSelected =
                            _selectedContactIds.contains(contact.id);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: contact.avatarColor,
                            child: Text(
                              contact.initials,
                              style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                          subtitle: Text(
                            contact.username,
                            style: const TextStyle(
                                color: Colors.black38, fontSize: 13),
                          ),
                          trailing: Transform.scale(
                            scale: 1.1,
                            child: Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF5C6BC0),
                              shape: const CircleBorder(),
                              side: const BorderSide(
                                  color: Colors.black12, width: 1.5),
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedContactIds.add(contact.id);
                                  } else {
                                    _selectedContactIds.remove(contact.id);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
            fontWeight: isLight ? FontWeight.normal : FontWeight.w500),
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
