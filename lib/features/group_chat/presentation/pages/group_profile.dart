import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Support for Clipboard deep links
import 'package:noteswap/features/group_chat/presentation/pages/groups_page.dart';
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
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  void _handleMessageAction() => Navigator.pop(context);
  void _handlePhoneAction() => print('Action: Call button tapped');

  // --- Mute notification logic tracking per-user in array collection ---
  void _handleMuteToggle(bool isMuted, List<dynamic> mutedList) async {
    try {
      await FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.groupId)
          .update({
        'mutedBy': isMuted
            ? FieldValue.arrayUnion([_currentUid])
            : FieldValue.arrayRemove([_currentUid])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isMuted ? "Notifications muted" : "Notifications unmuted"),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notifications: $e')),
      );
    }
  }

  // --- View Pinned Message Sheet Panel ---
  void _handlePinnedMessages() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('group_chats')
                .doc(widget.groupId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6366F1))),
                );
              }

              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final pinned = data?['pinnedMessage'] as Map<String, dynamic>?;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pinned Messages',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),
                    if (pinned == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "No pinned messages in this space.",
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.12)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Icon(Icons.pin_drop_rounded,
                                color: Color(0xFF6366F1)),
                          ),
                          title: Text(
                            pinned['senderName'] ?? 'Member',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1)),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              pinned['text'] ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A)),
                            ),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- Disappearing Messages Manager Options Sheet ---
  void _handleDisappearingMessages(String currentDuration) {
    final List<Map<String, dynamic>> options = [
      {"label": "Off", "value": "off"},
      {"label": "24 Hours", "value": "24h"},
      {"label": "7 Days", "value": "7d"},
      {"label": "90 Days", "value": "90d"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Disappearing Messages',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A)),
                  ),
                ),
                ...options.map((opt) {
                  final bool isSelected = currentDuration == opt['value'];
                  return ListTile(
                    title: Text(
                      opt['label'],
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : Color(0xFF0F172A),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF6366F1))
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await FirebaseFirestore.instance
                            .collection('group_chats')
                            .doc(widget.groupId)
                            .update({'disappearingDuration': opt['value']});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Failed to update timer configuration: $e')),
                        );
                      }
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Invite Deep Link Generator Copied to Clipboard ---
  void _handleInviteLink() async {
    final String deepLinkUrl =
        "https://noteswap.page.link/join?group=${widget.groupId}";
    await Clipboard.setData(ClipboardData(text: deepLinkUrl));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text("Group invite link copied to clipboard!"),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

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

                final prospectiveUsers = snapshot.data!.docs.where((doc) {
                  return !currentMembers.contains(doc.id);
                }).toList();

                if (prospectiveUsers.isEmpty) {
                  return const Center(
                      child: Text('All platform users are already members.'));
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
                        Navigator.pop(context);
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
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: Colors.black87),
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupsDisplayPage()))),
                ),
              ),
              title: const Text('Group info',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black)),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
            ),
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

        // Parse runtime database states dynamically
        final List<dynamic> mutedByList =
            groupData['mutedBy'] as List<dynamic>? ?? [];
        final bool isCurrentlyMuted = mutedByList.contains(_currentUid);

        final String disappearingDuration =
            groupData['disappearingDuration'] ?? "off";
        String displayDisappearingSubtitle = "Off";
        if (disappearingDuration == "24h")
          displayDisappearingSubtitle = "24 Hours";
        if (disappearingDuration == "7d")
          displayDisappearingSubtitle = "7 Days";
        if (disappearingDuration == "90d")
          displayDisappearingSubtitle = "90 Days";

        final hasPinned = groupData['pinnedMessage'] != null;
        final String pinSubtitle =
            hasPinned ? "1 message pinned" : "No pinned messages";

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
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: const Text('Group info',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black)),
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
                      onTap: () =>
                          _handleMuteToggle(!isCurrentlyMuted, mutedByList),
                    ),
                    const SizedBox(width: 24),
                    GroupActionButton(
                      imageAsset: Image.asset("assets/community/dots.png"),
                      label: 'More',
                      onTap: () {},
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
                  value: isCurrentlyMuted,
                  onChanged: (val) => _handleMuteToggle(val, mutedByList),
                  activeColor: const Color(0xFF6366F1),
                ),
                const Divider(height: 1, color: Color(0xffE4E5EF)),
                GroupListTile(
                  imagePath: 'assets/community/msg2.png',
                  bgColor: Colors.amber.shade50,
                  iconColor: Colors.amber.shade700,
                  title: 'Pinned messages',
                  subtitle: pinSubtitle,
                  onTap: _handlePinnedMessages,
                ),
                const Divider(height: 1, color: Color(0xffE4E5EF)),
                GroupListTile(
                  imagePath: 'assets/community/lock1.png',
                  bgColor: Colors.blue.shade50,
                  iconColor: Colors.blue,
                  title: 'Disappearing messages',
                  subtitle: displayDisappearingSubtitle,
                  onTap: () =>
                      _handleDisappearingMessages(disappearingDuration),
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
                                                BorderRadius.circular(16)),
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
                                            onPressed: () {},
                                          ),
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
