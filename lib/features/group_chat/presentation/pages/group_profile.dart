import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';
import '../../../community/Widgets/community_profile.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool _muteNotifications = false;

  void _handleMessageAction() => print('Action: Message button tapped');
  void _handlePhoneAction() => print('Action: Call button tapped');
  void _handleMuteAction() => print('Action: Quick Mute button tapped');
  void _handleMoreAction() => print('Action: More options button tapped');

  void _handleMuteToggle(bool newValue) {
    setState(() => _muteNotifications = newValue);
    print('Setting: Mute notifications updated to: $newValue');
  }

  void _handlePinnedMessages() =>
      print('Navigation: Pinned messages tile tapped');
  void _handleDisappearingMessages() =>
      print('Navigation: Disappearing messages tile tapped');
  void _handleInviteLink() => print('Action: Invite via link tile tapped');

  /// Displays a dialog listing users who aren't currently in the group
  void _handleAddMemberAction(List<dynamic> currentMembers) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter out users who are already part of this group chat
                final prospectiveUsers = snapshot.data!.docs.where((doc) {
                  return !currentMembers.contains(doc.id);
                }).toList();

                if (prospectiveUsers.isEmpty) {
                  return const Center(
                    child: Text('All platform users are already members.'),
                  );
                }

                return ListView.builder(
                  itemCount: prospectiveUsers.length,
                  itemBuilder: (context, index) {
                    final userData =
                        prospectiveUsers[index].data() as Map<String, dynamic>;
                    final String name = userData['name'] ?? 'Unknown User';
                    final String userId = prospectiveUsers[index].id;

                    return ListTile(
                      title: Text(name),
                      trailing:
                          const Icon(Icons.person_add, color: Colors.blue),
                      onTap: () async {
                        Navigator.pop(context); // Close the dialog immediately
                        try {
                          await FirebaseFirestore.instance
                              .collection('group_chats')
                              .doc(widget.groupId)
                              .update({
                            'members': FieldValue.arrayUnion([userId])
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('$name added successfully.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add member: $e')),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteUserAction(String memberId, String memberName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
            'Are you sure you want to remove $memberName from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('group_chats')
            .doc(widget.groupId)
            .update({
          'members': FieldValue.arrayRemove([memberId])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$memberName has been removed.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.groupId)
          .snapshots(),
      builder: (context, groupSnapshot) {
        if (groupSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                    "Error fetching group details: ${groupSnapshot.error}"),
              ),
            ),
          );
        }

        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      "Target group chat could not be found.\n\nChecked Collection: group_chats\nDocument ID: ${widget.groupId}",
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final groupData = groupSnapshot.data!.data() ?? {};
        final String creatorUid =
            (groupData["createdBy"] ?? "").toString().trim();
        final List<dynamic> memberIds =
            groupData['members'] as List<dynamic>? ?? [];
        final int dynamicCount = memberIds.length;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: Colors.black87),
                    onPressed: () => MainPage()),
              ),
            ),
            title: const Text(
              'Group info',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 2,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(thickness: 4, color: Colors.grey.shade100),
                GroupHeaderWidget1(groupId: widget.groupId),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GroupActionButton(
                      imageAsset: Image.asset("assets/community/msg.png"),
                      label: 'Message',
                      onTap: _handleMessageAction,
                    ),
                    const SizedBox(width: 24),
                    GroupActionButton(
                      imageAsset: Image.asset("assets/community/1phone.png"),
                      label: 'Call',
                      onTap: _handlePhoneAction,
                    ),
                    const SizedBox(width: 24),
                    GroupActionButton(
                      imageAsset: Image.asset("assets/community/mug.png"),
                      label: 'Mute',
                      onTap: _handleMuteAction,
                    ),
                    const SizedBox(width: 24),
                    GroupActionButton(
                      imageAsset: Image.asset("assets/community/dots.png"),
                      label: 'More',
                      onTap: _handleMoreAction,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(thickness: 8, color: Colors.grey.shade100),
                SwitchListTile(
                  secondary: const GroupIconTile(
                    imagePath: 'assets/community/mug.png',
                    bgColor: Color(0xFFF3E8FF),
                    iconColor: Colors.purple,
                  ),
                  title: const Text('Mute notifications',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Until you turn it back on',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  value: _muteNotifications,
                  onChanged: _handleMuteToggle,
                  activeColor: const Color(0xFF6366F1),
                ),
                const Divider(height: 1, color: Color(0xffE4E5EF)),
                GroupListTile(
                  imagePath: 'assets/community/msg2.png',
                  bgColor: Colors.amber.shade50,
                  iconColor: Colors.amber.shade700,
                  title: 'Pinned messages',
                  subtitle: '2 messages pinned',
                  onTap: _handlePinnedMessages,
                ),
                const Divider(height: 1, color: Color(0xffE4E5EF)),
                GroupListTile(
                  imagePath: 'assets/community/lock1.png',
                  bgColor: Colors.blue.shade50,
                  iconColor: Colors.blue,
                  title: 'Disappearing messages',
                  subtitle: 'Off',
                  onTap: _handleDisappearingMessages,
                ),
                const Divider(height: 1, color: Color(0xffE4E5EF)),
                GroupListTile(
                  imagePath: 'assets/community/upload.png',
                  bgColor: Colors.green.shade50,
                  iconColor: Colors.green,
                  title: 'Invite via link',
                  subtitle: 'Share group link',
                  onTap: _handleInviteLink,
                ),
                const Divider(height: 1, color: Color(0xffE4E5EF)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MEMBERS · $dynamicCount',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFFEEF2FF),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add,
                                  size: 16, color: Color(0xFF6366F1)),
                              onPressed: () =>
                                  _handleAddMemberAction(memberIds),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (memberIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            "No members found inside this group chat configuration."),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: memberIds.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final String memberId = memberIds[index].toString();

                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(memberId)
                                .snapshots(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return const SizedBox.shrink();
                              }

                              final userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              final String name =
                                  userData['name'] ?? 'Unknown User';
                              final bool isCurrentUser =
                                  memberId == currentUserId;
                              final bool isCreator = memberId == creatorUid;
                              final String firebaseImage =
                                  userData['profileImage'] ??
                                      userData['photoUrl'] ??
                                      '';

                              String initials = name.isNotEmpty
                                  ? name
                                      .trim()
                                      .split(' ')
                                      .map((l) => l[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase()
                                  : '??';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.indigo.shade50,
                                  backgroundImage: firebaseImage.isNotEmpty
                                      ? NetworkImage(firebaseImage)
                                      : null,
                                  child: firebaseImage.isEmpty
                                      ? Text(initials,
                                          style: TextStyle(
                                              color: Colors.indigo.shade800,
                                              fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                title: Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black87)),
                                subtitle: Text(
                                    isCurrentUser
                                        ? '${isCreator ? "Admin" : "Member"} · You'
                                        : (isCreator ? 'Admin' : 'Member'),
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13)),
                                trailing: isCurrentUser
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          isCreator ? 'Admin' : 'Member',
                                          style: const TextStyle(
                                              color: Color(0xFF6366F1),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Image.asset(
                                              "assets/community/mug.png",
                                              width: 20,
                                              height: 20,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.coffee,
                                                      color: Colors.grey,
                                                      size: 20),
                                            ),
                                            onPressed: () => print(
                                                'Action: Personal interaction button tapped'),
                                          ),
                                          // Only display the deletion vector option if the current app user is the group Admin
                                          if (currentUserId == creatorUid)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Color(0xFFEF4444)),
                                              onPressed: () =>
                                                  _handleDeleteUserAction(
                                                      memberId, name),
                                            ),
                                        ],
                                      ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GroupHeaderWidget1 extends StatelessWidget {
  final String groupId;

  const GroupHeaderWidget1({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('group_chats')
          .doc(groupId)
          .snapshots(),
      builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
          return const SizedBox(
            height: 150,
            child: Center(child: Text("Group header information unavailable")),
          );
        }

        final groupData = groupSnapshot.data!.data() ?? {};
        final String groupName = groupData["name"] ?? "Group";
        final String groupImage = groupData["imageUrl"] ?? "";
        final List<dynamic> memberIds =
            groupData['members'] as List<dynamic>? ?? [];
        final int memberCount = memberIds.length;

        return SizedBox(
          height: 150,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 40, right: 20, bottom: 30),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF818CF8),
                  backgroundImage:
                      groupImage.isNotEmpty ? NetworkImage(groupImage) : null,
                  child: groupImage.isEmpty
                      ? Text(
                          groupName.isNotEmpty
                              ? groupName[0].toUpperCase()
                              : "G",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Group · $memberCount members",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 15),
                      )
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
