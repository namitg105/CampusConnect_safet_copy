import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupActionButton extends StatelessWidget {
  final Widget imageAsset;
  final String label;
  final VoidCallback onTap;

  const GroupActionButton({
    super.key,
    required this.imageAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEEF2FF),
            child: SizedBox(
              width: 22,
              height: 22,
              child: imageAsset,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class GroupIconTile extends StatelessWidget {
  final String imagePath;
  final Color bgColor;
  final Color? iconColor;

  const GroupIconTile({
    super.key,
    required this.imagePath,
    required this.bgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        imagePath,
        color: iconColor,
        width: 22,
        height: 22,
      ),
    );
  }
}

class GroupListTile extends StatelessWidget {
  final String imagePath;
  final Color bgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const GroupListTile({
    super.key,
    required this.imagePath,
    required this.bgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GroupIconTile(
        imagePath: imagePath,
        bgColor: bgColor,
        iconColor: iconColor,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}

class GroupHeaderWidget extends StatelessWidget {
  final String groupId;

  const GroupHeaderWidget({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
      builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: Text("Group not found"),
            ),
          );
        }

        final group = groupSnapshot.data!.data() as Map<String, dynamic>;

        final String groupName = group["name"] ?? "Group";
        final String groupImage = group["imageUrl"] ?? "";

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("groups")
              .doc(groupId)
              .collection("members")
              .get(),
          builder: (context, memberSnapshot) {
            final memberCount = memberSnapshot.data?.docs.length ?? 0;

            return SizedBox(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 40,
                  right: 20,
                  bottom: 30,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF818CF8),
                      backgroundImage: groupImage.isNotEmpty
                          ? NetworkImage(groupImage)
                          : null,
                      child: groupImage.isEmpty
                          ? Text(
                              groupName.isNotEmpty
                                  ? groupName[0].toUpperCase()
                                  : "G",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
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
      },
    );
  }
}

class GroupMemberTile extends StatelessWidget {
  final String uid;
  final String creatorUid;

  const GroupMemberTile({
    super.key,
    required this.uid,
    required this.creatorUid,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = uid.trim() == creatorUid.trim();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data!.data() as Map<String, dynamic>;

        final name = user['name'] ?? 'Unknown';
        final image = user['photoUrl'] ?? user['profileImage'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 98),
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E7FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Admin",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAdmin ? "Admin · Group Owner" : "Member",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MemberActionButton extends StatelessWidget {
  final String imagePath;
  final Color bgColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const MemberActionButton({
    super.key,
    required this.imagePath,
    required this.bgColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          imagePath,
          color: iconColor,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
