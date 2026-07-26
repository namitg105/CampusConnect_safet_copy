import 'package:flutter/material.dart';

class GroupHeader extends StatelessWidget {
  final String groupName;
  final String groupImage;
  final int memberCount;
  final bool isCreator;
  final VoidCallback onEdit;

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const GroupHeader({
    super.key,
    required this.groupName,
    required this.groupImage,
    required this.memberCount,
    required this.isCreator,
    required this.onEdit,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
          decoration: const BoxDecoration(
            color: Color(0xff6139ED),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: groupImage.isNotEmpty
                            ? NetworkImage(groupImage)
                            : null,
                        child: groupImage.isEmpty
                            ? const Icon(
                                Icons.groups,
                                size: 32,
                                color: Colors.deepPurple,
                              )
                            : null,
                      ),
                      if (isCreator)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$memberCount Members",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: "Search members...",
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xff825CDA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 0,
          child: Image.asset(
            "assets/community/notification.png",
            width: 55,
            height: 55,
          ),
        ),
      ],
    );
  }
}

/// MEMBER SECTION

class MemberSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> members;
  final String creatorUid;

  const MemberSection({
    super.key,
    required this.title,
    required this.members,
    required this.creatorUid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xffEDE8FB)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          ...members.map(
            (member) => MemberTile(
              member: member,
              isAdmin: member["uid"] == creatorUid,
            ),
          ),
        ],
      ),
    );
  }
}

///======================================================
/// MEMBER TILE
///======================================================

class MemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isAdmin;

  const MemberTile({
    super.key,
    required this.member,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: (member["image"] ?? "").toString().isNotEmpty
                      ? NetworkImage(member["image"])
                      : null,
                  child: (member["image"] ?? "").toString().isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.deepPurple,
                        )
                      : null,
                ),
                title: Text(
                  member["name"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: isAdmin
                    ? const Text(
                        "Group Creator",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
                trailing: isAdmin
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Admin",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                        ),
                      )),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
