import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'assign_role.dart';

String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

class GroupProfilePage extends StatefulWidget {
  final String groupId;

  const GroupProfilePage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupProfilePage> createState() => _GroupProfilePageState();
}

class _GroupProfilePageState extends State<GroupProfilePage> {
  String creatorUid = "";
  String groupName = "";
  String groupImage = "";
  String groupDescription = "";
  bool isLoading = true;
  bool hasError = false;
  bool isCurrentMember = false;

  bool _muteNotifications = true;
  bool _pinChat = true;

  Stream<QuerySnapshot>? _membersStream;

  bool get isCurrentUserAdmin => currentUserId == creatorUid;

  @override
  void initState() {
    super.initState();
    _membersStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('members')
        .snapshots();
    loadGroup();
  }

  Future<void> loadGroup() async {
    try {
      if (currentUserId.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
        return;
      }

      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (!groupDoc.exists) {
        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
        return;
      }

      final memberDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('members')
          .doc(currentUserId)
          .get();

      final data = groupDoc.data()!;

      if (!mounted) return;

      setState(() {
        groupName = data["name"] ?? "Coding Club Core";
        groupImage = data["imageUrl"] ?? "";
        groupDescription = data["description"] ?? "";
        creatorUid = (data["createdBy"] ?? "").toString().trim();
        isCurrentMember = memberDoc.exists;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  Future<void> joinGroup() async {
    if (currentUserId.isEmpty || isCurrentMember) return;

    setState(() => isLoading = true);
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final memberRef = groupRef.collection('members').doc(currentUserId);

      final batch = FirebaseFirestore.instance.batch();

      batch.set(memberRef, {
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'Member',
      });

      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'remainingSeats': FieldValue.increment(-1),
      });

      await batch.commit();

      if (mounted) {
        setState(() {
          isCurrentMember = true;
        });
      }

      await loadGroup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the group!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to join: $e")),
        );
      }
    }
  }

  Future<void> leaveGroup() async {
    if (currentUserId.isEmpty || !isCurrentMember) return;

    setState(() => isLoading = true);
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final memberRef = groupRef.collection('members').doc(currentUserId);

      final batch = FirebaseFirestore.instance.batch();

      batch.delete(memberRef);

      batch.update(groupRef, {
        'memberCount': FieldValue.increment(-1),
        'remainingSeats': FieldValue.increment(1),
      });

      await batch.commit();

      if (mounted) {
        setState(() {
          isCurrentMember = false;
        });
      }

      await loadGroup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the group.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave group: $e')),
        );
      }
    }
  }

  Future<void> removeMemberByAdmin(String targetUid) async {
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final memberRef = groupRef.collection('members').doc(targetUid);

      final batch = FirebaseFirestore.instance.batch();

      batch.delete(memberRef);

      batch.update(groupRef, {
        'memberCount': FieldValue.increment(-1),
        'remainingSeats': FieldValue.increment(1),
      });

      await batch.commit();

      if (targetUid == currentUserId) {
        await loadGroup();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member removed successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    if (hasError) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Failed to load profile details.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _membersStream,
          builder: (context, snapshot) {
            List<QueryDocumentSnapshot> memberDocs = snapshot.data?.docs ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: groupImage.isNotEmpty
                                  ? NetworkImage(groupImage)
                                  : null,
                              child: groupImage.isEmpty
                                  ? Image.asset(
                                      'assets/community/blue_profile.png')
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E1B4B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_outlined,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      groupName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Image.asset("assets/community/p1.png")
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${groupDescription.isNotEmpty ? groupDescription : "No description"} · ${memberDocs.length} ${memberDocs.length == 1 ? 'member' : 'members'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8B899F),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 36, left: 20),
                                child: Row(
                                  children: [
                                    isCurrentMember
                                        ? _buildHeaderAction(
                                            Icons.directions_run_rounded,
                                            "Leave",
                                            leaveGroup,
                                          )
                                        : _buildHeaderAction(
                                            Icons.person_add_alt_1_outlined,
                                            "Join Group",
                                            joinGroup,
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf6f3fe),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.groups_outlined,
                                color: Color(0xFF6366F1)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VIT Vellore',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                Text(
                                  'Community · 18 sections',
                                  style: TextStyle(
                                      color: Color(0xff8B899F), fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 5, left: 25),
                    child: Text(
                      'Unlocking Potential, One Line of Code at a Time',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Media, links and docs',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('48',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 15)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 75,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                            width: 75,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset("assets/community/p3.png"));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildListTile(
                      "assets/community/search.png", "Search Messages",
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey)),
                  _buildListTile(
                    "assets/community/blue_noti.png",
                    "Mute Notifications",
                    trailing: Text(_muteNotifications ? 'on' : 'off',
                        style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold)),
                    onTap: () => setState(
                        () => _muteNotifications = !_muteNotifications),
                  ),
                  _buildListTile(
                    "assets/community/pin_1.png",
                    "Pin Chat",
                    trailing: Text(_pinChat ? 'on' : 'off',
                        style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold)),
                    onTap: () => setState(() => _pinChat = !_pinChat),
                  ),
                  _buildListTile(
                      "assets/community/noti.png", "Notification Settings",
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Group Members (${memberDocs.length})',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (memberDocs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("No members found"),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: memberDocs.length,
                      itemBuilder: (context, index) {
                        final memberDoc = memberDocs[index];
                        final memberId = memberDoc.id;
                        final memberData =
                            memberDoc.data() as Map<String, dynamic>?;

                        // Get explicit role assigned in member subcollection or default
                        final String customRole = memberData?['role'] ?? '';
                        final bool isCreator = memberId == creatorUid;

                        return GroupMemberTile(
                          uid: memberId,
                          groupId: widget.groupId,
                          currentGroupCreatorUid: creatorUid,
                          isCreator: isCreator,
                          explicitRole: customRole,
                          isCurrentUserAdmin: isCurrentUserAdmin,
                          showDeleteOption: isCurrentUserAdmin && !isCreator,
                          onDeletePressed: () {
                            _showDeleteConfirmationDialog(memberId);
                          },
                        );
                      },
                    ),
                  if (isCurrentMember)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF1F2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                          onPressed: leaveGroup,
                          icon: const Icon(Icons.logout,
                              color: Color(0xFFE11D48), size: 20),
                          label: const Text(
                            'Leave Group',
                            style: TextStyle(
                                color: Color(0xFFE11D48),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }

  void _showDeleteConfirmationDialog(String targetUid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Member"),
          content: const Text(
              "Are you sure you want to remove this member from the group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                removeMemberByAdmin(targetUid);
              },
              child: const Text("Remove",
                  style: TextStyle(color: Color(0xFFE11D48))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 20),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF6139ED),
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String imagePath,
    String title, {
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading:
          Image.asset(imagePath, width: 22, height: 22, fit: BoxFit.contain),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class GroupMemberTile extends StatelessWidget {
  final String uid;
  final String groupId;
  final String currentGroupCreatorUid;
  final bool isCreator;
  final String explicitRole;
  final bool isCurrentUserAdmin;
  final bool showDeleteOption;
  final VoidCallback onDeletePressed;

  const GroupMemberTile({
    super.key,
    required this.uid,
    required this.groupId,
    required this.currentGroupCreatorUid,
    required this.isCreator,
    required this.explicitRole,
    required this.isCurrentUserAdmin,
    required this.showDeleteOption,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SizedBox(
              height: 44,
              child: Center(
                child: LinearProgressIndicator(
                  color: Color(0xFF6366F1),
                  backgroundColor: Color(0xFFEEF2FF),
                ),
              ),
            ),
          );
        }

        String displayName = "Loading User...";
        String username = "";
        String displayImage = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            displayName =
                userData['name'] ?? userData['displayName'] ?? "Unnamed User";
            displayImage = userData['imageUrl'] ??
                userData['photoUrl'] ??
                userData['profileImage'] ??
                "";

            // Fetch explicit handle or format fallback dynamically using their name
            if (userData['username'] != null) {
              username = userData['username'];
            } else if (userData['handle'] != null) {
              username = userData['handle'];
            } else {
              username = '';
            }
          }
        } else {
          username = '@loading';
        }

        // Determine badge label
        String roleLabel = isCreator ? 'Admin' : 'Member';
        if (!isCreator && explicitRole.isNotEmpty) {
          roleLabel = explicitRole;
        }

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: isCurrentUserAdmin
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignRolePage(
                        groupId: groupId,
                        targetUid: uid,
                        targetName: displayName,
                        targetUsername: username,
                        targetImageUrl: displayImage,
                        currentGroupCreatorUid: currentGroupCreatorUid,
                      ),
                    ),
                  );
                }
              : null,
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEEF2FF),
            backgroundImage:
                displayImage.isNotEmpty ? NetworkImage(displayImage) : null,
            child: displayImage.isEmpty
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                        fontSize: 16),
                  )
                : null,
          ),
          title: Text(
            displayName,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xff14142B),
                fontSize: 15),
          ),
          subtitle: Text(
            username,
            style: const TextStyle(color: Color(0xff8B899F), fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: roleLabel == 'Admin'
                      ? const Color(0xFFF5F3FF)
                      : (roleLabel == 'Moderator'
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF0FDF4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(
                    color: roleLabel == 'Admin'
                        ? const Color(0xFF6366F1)
                        : (roleLabel == 'Moderator'
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF16A34A)),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (showDeleteOption) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Color(0xFFE11D48)),
                  onPressed: onDeletePressed,
                )
              ]
            ],
          ),
        );
      },
    );
  }
}
