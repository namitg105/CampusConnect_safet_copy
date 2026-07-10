import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Widgets/profile_page.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;

  const GroupInfoPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  String groupName = "";
  String groupImage = "";
  String creatorUid = "";
  String creatorName = "";

  List<Map<String, dynamic>> members = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  List<Map<String, dynamic>> searchResults = [];
  void searchMembers(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    setState(() {
      searchResults = members.where((member) {
        final name = (member["name"] ?? "").toString().toLowerCase();
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      await loadGroupInfo();
      await loadMembers();
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> changeGroupImage() async {
    try {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('group_images')
          .child('${widget.groupId}.jpg');

      await ref.putFile(file);

      final imageUrl = await ref.getDownloadURL();

      await firestore.collection('groups').doc(widget.groupId).update({
        'imageUrl': imageUrl,
      });

      setState(() {
        groupImage = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group image updated'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> loadGroupInfo() async {
    final groupDoc =
        await firestore.collection('groups').doc(widget.groupId).get();

    if (!groupDoc.exists) return;

    final data = groupDoc.data()!;

    groupName = data['name'] ?? '';
    groupImage = data['imageUrl'] ?? '';
    creatorUid = data['createdBy'] ?? '';

    debugPrint("Group Data: $data");
    debugPrint("Creator UID: $creatorUid");
    final creatorDoc =
        await firestore.collection('users').doc(creatorUid).get();

    print("Creator Exists: ${creatorDoc.exists}");

    if (creatorDoc.exists) {
      print("Creator Data: ${creatorDoc.data()}");

      final creator = creatorDoc.data()!;

      creatorName = creator['name'] ??
          creator['displayName'] ??
          creator['username'] ??
          creator['fullName'] ??
          "Unknown";
    }

    print("Creator Name: $creatorName");

    if (creatorUid.isNotEmpty) {
      final creatorDoc =
          await firestore.collection('users').doc(creatorUid).get();

      if (creatorDoc.exists) {
        final creator = creatorDoc.data()!;

        debugPrint("Creator Data: $creator");

        creatorName = creator['name'] ??
            creator['displayName'] ??
            creator['username'] ??
            creator['fullName'] ??
            "Unknown";
      }
    }
  }

  Future<void> loadMembers() async {
    final memberSnapshot = await firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('members')
        .get();

    debugPrint("Members Count: ${memberSnapshot.docs.length}");

    members.clear();

    for (final memberDoc in memberSnapshot.docs) {
      final uid = memberDoc.id;

      debugPrint("Loading member: $uid");

      final userDoc = await firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        debugPrint("User document not found for $uid");
        continue;
      }

      final user = userDoc.data()!;

      debugPrint("User Data: $user");

      members.add({
        "uid": uid,
        "name": user['name'] ??
            user['displayName'] ??
            user['username'] ??
            user['fullName'] ??
            "Unknown User",
        "image": user['profileImage'] ??
            user['photoUrl'] ??
            user['photoURL'] ??
            user['image'] ??
            "",
      });
    }

    members.sort((a, b) {
      if (a["uid"] == creatorUid) return -1;
      if (b["uid"] == creatorUid) return 1;
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = currentUid == creatorUid;

    final admins = members.where((e) => e["uid"] == creatorUid).toList();
    final normalMembers = members.where((e) => e["uid"] != creatorUid).toList();

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            GroupHeader(
              groupName: groupName,
              groupImage: groupImage,
              memberCount: members.length,
              isCreator: isCreator,
              onEdit: changeGroupImage,
              controller: searchController,
              onChanged: searchMembers,
            ),
            Expanded(
              child: ListView(
                children: [
                  if (searchResults.isNotEmpty)
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(0),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final member = searchResults[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  (member["image"] as String).isNotEmpty
                                      ? NetworkImage(member["image"])
                                      : null,
                              child: (member["image"] as String).isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(member["name"]),
                            onTap: () {
                              searchController.clear();

                              setState(() {
                                searchResults.clear();
                              });

                              // Optional: Open member profile here
                            },
                          );
                        },
                      ),
                    ),
                  MemberSection(
                    title: "Admins & Mods",
                    members: admins,
                    creatorUid: creatorUid,
                  ),
                  MemberSection(
                    title: "Members",
                    members: members
                        .where((member) => member["uid"] != creatorUid)
                        .toList(),
                    creatorUid: creatorUid,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
