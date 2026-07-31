import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../chat/presentation/cubits/chat_cubit.dart';
import '../../../chat/presentation/pages/chatPage.dart';
import '../../../events/presentation/screens/event_community.dart';
import 'assign_role.dart';
import 'media_link.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_2/chat_screen.dart';

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

class _GroupProfilePageState extends State<GroupProfilePage>
    with SingleTickerProviderStateMixin {
  String _getGroupInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'G';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  late TabController _tabController;

  String creatorUid = "";
  String groupName = "";
  String groupImage = "";
  String bannerImage = "";
  String groupDescription = "";
  String category = "Technology";
  bool isPublic = true;
  List<String> rulesList = [];
  String location = "VIT Vellore";
  String createdOn = "12 Jan 2023";
  String creatorName = "Admin";
  int memberCount = 0;

  // --- RATING STATE ---
  double averageRating = 0.0;
  int ratingCount = 0;
  int userExistingRating = 0;
  String userExistingReview = "";

  // --- DYNAMIC PINNED ANNOUNCEMENT STATE ---
  Map<String, dynamic> pinnedAnnouncement = {};

  bool isLoading = true;
  bool hasError = false;
  bool isCurrentMember = false;
  bool hasPendingRequest = false;

  String _selectedFilterRole = 'All members';
  String _searchQuery = '';

  Stream<QuerySnapshot>? _membersStream;
  Stream<QuerySnapshot>? _requestsStream;

  bool get isCurrentUserAdmin => currentUserId == creatorUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _membersStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('members')
        .snapshots();

    _requestsStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('join_requests')
        .snapshots();

    loadGroup();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      final requestDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('join_requests')
          .doc(currentUserId)
          .get();

      // Fetch user's existing review if present
      final reviewDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('reviews')
          .doc(currentUserId)
          .get();

      final data = groupDoc.data()!;
      creatorUid =
          (data["createdBy"] ?? data["adminId"] ?? "").toString().trim();

      if (creatorUid.isNotEmpty) {
        final creatorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(creatorUid)
            .get();
        if (creatorDoc.exists) {
          creatorName = creatorDoc.data()?['name'] ??
              creatorDoc.data()?['displayName'] ??
              'Admin';
        }
      }

      if (!mounted) return;

      setState(() {
        groupName = data["name"] ?? "AI & ML Society";
        groupImage = data["imageUrl"] ?? "";
        bannerImage = data["bannerUrl"] ?? "";
        groupDescription = data["description"] ?? "";

        category = data["category"] ?? "Education";
        isPublic = data["isPublic"] ?? true;
        rulesList = List<String>.from(data["rules"] ?? []);

        location = data["location"] ?? "VIT Vellore";

        // Aggregate ratings
        averageRating = (data["averageRating"] ?? 0.0).toDouble();
        ratingCount = data["ratingCount"] ?? 0;

        if (reviewDoc.exists) {
          final reviewData = reviewDoc.data();
          userExistingRating = (reviewData?['rating'] ?? 0).toInt();
          userExistingReview = reviewData?['review'] ?? "";
        }

        // Fetch Pinned Announcement map from Firestore
        pinnedAnnouncement = Map<String, dynamic>.from(
          data["pinnedAnnouncement"] ?? {},
        );

        if (data["createdAt"] != null && data["createdAt"] is Timestamp) {
          final DateTime date = (data["createdAt"] as Timestamp).toDate();
          createdOn = "${date.day} ${_getMonthName(date.month)} ${date.year}";
        } else {
          createdOn = data["createdOn"] ?? "Recently";
        }

        isCurrentMember = memberDoc.exists;
        hasPendingRequest = requestDoc.exists;
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

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // --- MEMBER FUNCTION: RATE COMMUNITY DIALOG ---
  void _showRateCommunityDialog() {
    if (!isCurrentMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only members can rate this community.')),
      );
      return;
    }

    int selectedRating = userExistingRating > 0 ? userExistingRating : 5;
    final reviewController = TextEditingController(text: userExistingReview);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Rate this Community',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        icon: Icon(
                          starVal <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starVal;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a short review (optional)...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _submitRating(
                        selectedRating, reviewController.text.trim());
                  },
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- ATOMIC RATING SUBMISSION VIA FIRESTORE TRANSACTION ---
  Future<void> _submitRating(int newRating, String reviewText) async {
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final reviewRef = groupRef.collection('reviews').doc(currentUserId);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      String userName = 'User';
      String userPhoto = '';
      if (userDoc.exists) {
        final userData = userDoc.data();
        userName = userData?['name'] ?? userData?['displayName'] ?? 'User';
        userPhoto = userData?['imageUrl'] ?? userData?['photoUrl'] ?? '';
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final groupSnapshot = await transaction.get(groupRef);
        final reviewSnapshot = await transaction.get(reviewRef);

        if (!groupSnapshot.exists) return;

        double currentAvg =
            (groupSnapshot.data()?['averageRating'] ?? 0.0).toDouble();
        int currentCount = groupSnapshot.data()?['ratingCount'] ?? 0;

        double newAvg;
        int newCount;

        if (reviewSnapshot.exists) {
          int oldRating = (reviewSnapshot.data()?['rating'] ?? 0).toInt();
          double totalSum = (currentAvg * currentCount) - oldRating + newRating;
          newCount = currentCount;
          newAvg = newCount > 0 ? totalSum / newCount : 0.0;
        } else {
          double totalSum = (currentAvg * currentCount) + newRating;
          newCount = currentCount + 1;
          newAvg = totalSum / newCount;
        }

        transaction.set(reviewRef, {
          'rating': newRating,
          'review': reviewText,
          'userId': currentUserId,
          'userName': userName,
          'userPhoto': userPhoto,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(groupRef, {
          'averageRating': double.parse(newAvg.toStringAsFixed(1)),
          'ratingCount': newCount,
        });
      });

      setState(() {
        userExistingRating = newRating;
        userExistingReview = reviewText;
      });

      await loadGroup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: $e')),
        );
      }
    }
  }

  // --- ADMIN FUNCTION: EDIT DESCRIPTION ---
  void _showEditDescriptionDialog() {
    final controller = TextEditingController(text: groupDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter community description...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final newDesc = controller.text.trim();
                Navigator.pop(context);

                try {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .update({'description': newDesc});

                  setState(() {
                    groupDescription = newDesc;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Description updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- ADMIN FUNCTION: EDIT PINNED ANNOUNCEMENT ---
  void _showEditAnnouncementDialog() {
    final titleController =
        TextEditingController(text: pinnedAnnouncement['title'] ?? '');
    final descController =
        TextEditingController(text: pinnedAnnouncement['description'] ?? '');
    final dateTimeController =
        TextEditingController(text: pinnedAnnouncement['dateTime'] ?? '');
    final locationController =
        TextEditingController(text: pinnedAnnouncement['location'] ?? '');
    final btnController =
        TextEditingController(text: pinnedAnnouncement['buttonText'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Pinned Announcement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Date & Time',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Venue',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: btnController,
                  decoration: const InputDecoration(
                    labelText: 'Button Label',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final updatedData = {
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                  'dateTime': dateTimeController.text.trim(),
                  'location': locationController.text.trim(),
                  'buttonText': btnController.text.trim(),
                };

                Navigator.pop(context);

                try {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .update({'pinnedAnnouncement': updatedData});

                  setState(() {
                    pinnedAnnouncement = updatedData;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Announcement updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- SUBMIT JOIN REQUEST OR DIRECT JOIN ---
  Future<void> requestToJoinGroup() async {
    if (currentUserId.isEmpty || isCurrentMember || hasPendingRequest) return;

    setState(() => isLoading = true);
    try {
      if (isPublic) {
        // Public Community: Automatically join directly without sending a request to admin!
        final groupRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId);
        final memberRef = groupRef.collection('members').doc(currentUserId);
        final joinedGroupRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('joinedGroups')
            .doc(widget.groupId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(memberRef, {
            'uid': currentUserId,
            'joinedAt': FieldValue.serverTimestamp(),
          });
          transaction.set(joinedGroupRef, {
            'joinedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(groupRef, {
            'memberCount': FieldValue.increment(1),
            'remainingSeats': FieldValue.increment(-1),
          });
        });

        if (mounted) {
          setState(() {
            isCurrentMember = true;
            isLoading = false;
            memberCount += 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Joined $groupName!')),
          );
        }
      } else {
        // Private Community: Send join request to admin for approval
        final requestRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('join_requests')
            .doc(currentUserId);

        await requestRef.set({
          'requestedAt': FieldValue.serverTimestamp(),
          'userId': currentUserId,
          'status': 'pending',
        });

        if (mounted) {
          setState(() {
            hasPendingRequest = true;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Join request sent! Waiting for admin approval.')),
          );
        }
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

  // --- ADMIN APPROVE MEMBER REQUEST ---
  Future<void> approveMemberRequest(String targetUid) async {
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final memberRef = groupRef.collection('members').doc(targetUid);
      final requestRef = groupRef.collection('join_requests').doc(targetUid);

      final batch = FirebaseFirestore.instance.batch();
      batch.set(memberRef, {
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'Member',
        'muted': false,
      });
      batch.delete(requestRef);
      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'remainingSeats': FieldValue.increment(-1),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member request approved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve request: $e')),
        );
      }
    }
  }

  // --- ADMIN REJECT MEMBER REQUEST ---
  Future<void> rejectMemberRequest(String targetUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('join_requests')
          .doc(targetUid)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Join request declined.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline request: $e')),
        );
      }
    }
  }

  // --- LEAVE GROUP / TRANSFER OWNERSHIP ---
  Future<void> leaveGroup() async {
    if (currentUserId.isEmpty || !isCurrentMember) return;

    if (isCurrentUserAdmin) {
      try {
        final membersSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('members')
            .get();

        final otherMembers = membersSnapshot.docs
            .where((doc) => doc.id != currentUserId)
            .toList();

        if (otherMembers.isEmpty) {
          await _showDeleteGroupConfirmation();
        } else {
          _showTransferOwnershipDialog(otherMembers);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to check members: $e')),
          );
        }
      }
      return;
    }

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

      if (mounted) setState(() => isCurrentMember = false);
      await loadGroup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the community.')),
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

  void _showTransferOwnershipDialog(List<QueryDocumentSnapshot> otherMembers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select New Community Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'As the primary admin, you must transfer ownership to another member before leaving.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: otherMembers.length,
                  itemBuilder: (context, index) {
                    final memberUid = otherMembers[index].id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberUid)
                          .get(),
                      builder: (context, userSnap) {
                        String name = 'User';
                        String photo = '';

                        if (userSnap.hasData && userSnap.data!.exists) {
                          final data =
                              userSnap.data!.data() as Map<String, dynamic>?;
                          name =
                              data?['name'] ?? data?['displayName'] ?? 'User';
                          photo = data?['imageUrl'] ?? data?['photoUrl'] ?? '';
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                photo.isNotEmpty ? NetworkImage(photo) : null,
                            child: photo.isEmpty
                                ? Text(name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : 'U')
                                : null,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _transferOwnershipAndLeave(memberUid, name);
                            },
                            child: const Text(
                              'Assign & Leave',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _transferOwnershipAndLeave(
      String newAdminUid, String newAdminName) async {
    setState(() => isLoading = true);
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final currentAdminRef = groupRef.collection('members').doc(currentUserId);
      final newAdminRef = groupRef.collection('members').doc(newAdminUid);

      final batch = FirebaseFirestore.instance.batch();

      batch.update(groupRef, {
        'createdBy': newAdminUid,
        'adminId': newAdminUid,
        'memberCount': FieldValue.increment(-1),
        'remainingSeats': FieldValue.increment(1),
      });

      batch.update(newAdminRef, {
        'role': 'Admin',
      });

      batch.delete(currentAdminRef);

      await batch.commit();

      if (mounted) setState(() => isCurrentMember = false);
      await loadGroup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Transferred admin rights to $newAdminName and left community.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to transfer ownership: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteGroupConfirmation() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Community?'),
          content: const Text(
            'You are the only member left in this community. Leaving will permanently delete it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
              ),
              onPressed: () {
                Navigator.pop(context);
                _deleteGroup();
              },
              child: const Text('Delete & Leave',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGroup() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community deleted successfully.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete community: $e')),
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

      if (targetUid == currentUserId) await loadGroup();

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

  void _shareGroupInfo() {
    final String shareText =
        "Check out '$groupName' on NoteSwap! Community Profile Link: noteswap://community/${widget.groupId}";
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Community profile link copied to clipboard!')),
    );
  }

  void _navigateToChatPage() {
    if (!isCurrentMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only approved members can access community chat.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ChatCubit>(),
          child: ChatPage(
            groupId: widget.groupId,
            groupName: groupName,
          ),
        ),
      ),
    );
  }

  void _showAddMemberModal() {
    if (!isCurrentUserAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only community admins can invite members directly.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Add Members to Community",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final userDoc = users[index];
                          final userData =
                              userDoc.data() as Map<String, dynamic>;
                          final userId = userDoc.id;
                          final name = userData['name'] ??
                              userData['displayName'] ??
                              'User';
                          final image = userData['imageUrl'] ??
                              userData['photoUrl'] ??
                              '';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  image.isNotEmpty ? NetworkImage(image) : null,
                              child: image.isEmpty
                                  ? Text(name[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(name),
                            subtitle: Text(userData['email'] ?? ''),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                await _addMemberToGroup(userId);
                              },
                              child: const Text('Add',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _addMemberToGroup(String uid) async {
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final memberRef = groupRef.collection('members').doc(uid);

      final doc = await memberRef.get();
      if (doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is already a member.')),
          );
        }
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      batch.set(memberRef, {
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'Member',
        'muted': false,
      });
      batch.update(groupRef, {
        'memberCount': FieldValue.increment(1),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

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
      body: StreamBuilder<QuerySnapshot>(
        stream: _membersStream,
        builder: (context, snapshot) {
          final memberDocs = snapshot.data?.docs ?? [];
          memberCount = memberDocs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BANNER WITH BACK BUTTON ---
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: topPadding + 10),
                    height: 180 + topPadding,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: bannerImage.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(bannerImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: bannerImage.isEmpty
                        ? Image.asset(
                            'assets/community/default_prof.png',
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  Positioned(
                    top: topPadding + 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      radius: 18,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),

              // --- PROFILE PHOTO & BADGES ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E0854),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: groupImage.isNotEmpty
                              ? Image.network(groupImage, fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    _getGroupInitials(groupName),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              groupName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildBadge(category, const Color(0xFFF0F0FF),
                                    const Color(0xFF6366F1)),
                                _buildBadge(
                                  isPublic ? 'Public' : 'Private',
                                  isPublic
                                      ? const Color(0xFFF0F0FF)
                                      : const Color(0xFFFFF1F2),
                                  isPublic
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFE11D48),
                                  icon: isPublic
                                      ? Icons.language
                                      : Icons.lock_outline,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- STATS ROW WITH STAR RATING ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                        onTap:
                            isCurrentMember ? _showRateCommunityDialog : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                averageRating > 0
                                    ? "$averageRating ($ratingCount)"
                                    : "Rate Us",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                          Icons.people_outline, "$memberCount Members"),
                      const SizedBox(width: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('groups')
                            .doc(widget.groupId)
                            .collection('members')
                            .snapshots(),
                        builder: (context, onlineSnap) {
                          int onlineCount = 0;
                          if (onlineSnap.hasData) {
                            onlineCount = onlineSnap.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>?;
                              return data?['isOnline'] == true;
                            }).length;
                          }
                          if (onlineCount == 0) onlineCount = 1;

                          return _buildStatItem(
                              Icons.circle, "$onlineCount Online",
                              iconColor: Colors.green);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- ACTION BUTTONS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildUniformActionButton(
                        label: isCurrentMember
                            ? 'Joined'
                            : (hasPendingRequest ? 'Requested' : 'Join'),
                        iconData: isCurrentMember
                            ? Icons.check
                            : (hasPendingRequest
                                ? Icons.hourglass_top
                                : Icons.add),
                        onTap: isCurrentMember
                            ? leaveGroup
                            : (hasPendingRequest ? () {} : requestToJoinGroup),
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildUniformActionButton(
                      label: "Community Chat",
                      assetPath: 'assets/community/msg_1.png',
                      onTap: _navigateToChatPage,
                    ),
                    if (isCurrentUserAdmin) ...[
                      const SizedBox(width: 8),
                      _buildUniformActionButton(
                        label: "Invite",
                        onTap: _showAddMemberModal,
                      ),
                    ],
                    const SizedBox(width: 8),
                    _buildUniformActionButton(
                      label: "Share",
                      onTap: _shareGroupInfo,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- TAB BAR ---
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF6366F1),
                unselectedLabelColor: const Color(0xFF6366F1),
                indicatorColor: const Color(0xFF6366F1),
                indicatorWeight: 2,
                labelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.normal),
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.home_outlined, size: 18),
                    text: 'Overview',
                    iconMargin: EdgeInsets.only(bottom: 2.0),
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_month_outlined, size: 18),
                    text: 'Events',
                    iconMargin: EdgeInsets.only(bottom: 2.0),
                  ),
                  Tab(
                    icon: Icon(Icons.people_alt_outlined, size: 18),
                    text: 'Members',
                    iconMargin: EdgeInsets.only(bottom: 2.0),
                  ),
                  Tab(
                    icon: Icon(Icons.folder_outlined, size: 18),
                    text: 'Files',
                    iconMargin: EdgeInsets.only(bottom: 2.0),
                  ),
                ],
              ),

              // --- TAB BAR VIEW ---
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(memberDocs),
                    isCurrentMember
                        ? UpcomingEventsSection(
                            groupId: widget.groupId,
                            isCurrentUserAdmin: isCurrentUserAdmin,
                          )
                        : _buildRestrictedTabPlaceholder('Events'),
                    isCurrentMember
                        ? _buildMembersTab(memberDocs)
                        : _buildRestrictedTabPlaceholder('Members'),
                    isCurrentMember
                        ? MediaLinksDocsPage(groupId: widget.groupId)
                        : _buildRestrictedTabPlaceholder('Files'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- RESTRICTED PLACEHOLDER ---
  Widget _buildRestrictedTabPlaceholder(String tabName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 32,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Join to Access $tabName",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasPendingRequest
                  ? "Your join request is pending approval by an admin."
                  : "Request to join this community to view $tabName, participate in events, and chat.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            if (!hasPendingRequest) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: requestToJoinGroup,
                child: const Text(
                  "Request to Join",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- UNIFORM BUTTON BUILDER ---
  Widget _buildUniformActionButton({
    required String label,
    required VoidCallback onTap,
    String? assetPath,
    IconData? iconData,
    bool isPrimary = false,
  }) {
    final Color bgColor =
        isPrimary ? const Color(0xFF6366F1) : const Color(0xFFF5F3FF);
    final Color fgColor = isPrimary ? Colors.white : const Color(0xFF6366F1);

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (assetPath != null) ...[
                  Image.asset(
                    assetPath,
                    width: 16,
                    height: 16,
                    color: fgColor,
                  ),
                  const SizedBox(width: 6),
                ] else if (iconData != null) ...[
                  Icon(
                    iconData,
                    size: 16,
                    color: fgColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- OVERVIEW TAB ---
  Widget _buildOverviewTab(List<QueryDocumentSnapshot> memberDocs) {
    final bool hasAnnouncementData = pinnedAnnouncement.isNotEmpty &&
        (pinnedAnnouncement['title']?.toString().trim().isNotEmpty ?? false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- COMMUNITY STAR RATING SUMMARY ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFFDE68A)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Community Rating',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < averageRating.floor()
                                      ? Icons.star_rounded
                                      : (index < averageRating
                                          ? Icons.star_half_rounded
                                          : Icons.star_outline_rounded),
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($ratingCount)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isCurrentMember)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onPressed: _showRateCommunityDialog,
                        icon: const Icon(Icons.rate_review, size: 14),
                        label: Text(
                          userExistingRating > 0 ? 'Edit Rating' : 'Rate',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- DESCRIPTION CONTAINER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isCurrentUserAdmin)
                      InkWell(
                        onTap: _showEditDescriptionDialog,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.edit_outlined,
                              size: 16, color: Color(0xFF6366F1)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  groupDescription.isNotEmpty
                      ? groupDescription
                      : 'No description provided.',
                  style: TextStyle(
                    fontSize: 12,
                    color: groupDescription.isNotEmpty
                        ? const Color(0xFF475569)
                        : Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- PINNED ANNOUNCEMENT CONTAINER ---
          // Render ONLY if: Admin (can edit) OR if an announcement exists
          if (isCurrentUserAdmin || hasAnnouncementData) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.push_pin_outlined,
                              size: 16, color: Color(0xFF6366F1)),
                          SizedBox(width: 6),
                          Text(
                            'Pinned Announcement',
                            style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      if (isCurrentUserAdmin)
                        InkWell(
                          onTap: _showEditAnnouncementDialog,
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(Icons.edit_outlined,
                                size: 16, color: Color(0xFF6366F1)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!hasAnnouncementData && isCurrentUserAdmin)
                    const Text(
                      'No pinned announcement set yet. Tap the edit icon above to create one.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B4B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.campaign_outlined,
                              color: Colors.indigoAccent, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pinnedAnnouncement['title'] != null &&
                                  pinnedAnnouncement['title']
                                      .toString()
                                      .isNotEmpty)
                                Text(
                                  pinnedAnnouncement['title'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              if (pinnedAnnouncement['description'] != null &&
                                  pinnedAnnouncement['description']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  pinnedAnnouncement['description'],
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (pinnedAnnouncement['dateTime'] != null &&
                                  pinnedAnnouncement['dateTime']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 12, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Text(
                                      pinnedAnnouncement['dateTime'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                              if (pinnedAnnouncement['location'] != null &&
                                  pinnedAnnouncement['location']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 12, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Text(
                                      pinnedAnnouncement['location'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                              if (pinnedAnnouncement['buttonText'] != null &&
                                  pinnedAnnouncement['buttonText']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEEF2FF),
                                      foregroundColor: const Color(0xFF6366F1),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      pinnedAnnouncement['buttonText'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About Community',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      _buildAboutRow(
                          Icons.person_outline, 'Created by', creatorName,
                          valueColor: const Color(0xFF6366F1)),
                      _buildAboutRow(
                          Icons.access_time, 'Created on', createdOn),
                      _buildAboutRow(
                        Icons.visibility_outlined,
                        'Visibility',
                        isPublic ? 'Public' : 'Private',
                        valueColor: isPublic ? Colors.green : Colors.red,
                      ),
                      _buildAboutRow(
                          Icons.bookmark_outline, 'Category', category),
                      _buildAboutRow(
                          Icons.location_on_outlined, 'Location', location),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('Community Rules',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.check_circle,
                              color: Color(0xFF6366F1), size: 14),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (rulesList.isEmpty)
                        const Text(
                          'No rules specified.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        )
                      else
                        ...rulesList.map(
                          (rule) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $rule',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black87),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- RECENT COMMUNITY REVIEWS FEED ---
          const Text('Member Reviews',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('reviews')
                .orderBy('updatedAt', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No reviews yet. Be the first to leave a review!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }

              final reviewDocs = snapshot.data!.docs;

              return Column(
                children: reviewDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final rRating = data['rating'] ?? 5;
                  final rReview = data['review'] ?? '';
                  final rName = data['userName'] ?? 'Member';
                  final rPhoto = data['userPhoto'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              rPhoto.isNotEmpty ? NetworkImage(rPhoto) : null,
                          child: rPhoto.isEmpty
                              ? Text(rName[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < rRating
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (rReview.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  rReview,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black87),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- MEMBERS TAB ---
  Widget _buildMembersTab(List<QueryDocumentSnapshot> memberDocs) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    int newThisWeekCount = 0;
    for (var doc in memberDocs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['joinedAt'] != null) {
        final Timestamp? timestamp = data['joinedAt'] as Timestamp?;
        if (timestamp != null && timestamp.toDate().isAfter(sevenDaysAgo)) {
          newThisWeekCount++;
        }
      }
    }

    return StatefulBuilder(
      builder: (context, setTabState) {
        final filteredDocs = memberDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          final role = (data?['role'] ?? 'Member').toString().toLowerCase();
          final isCreator = doc.id == creatorUid;

          if (_selectedFilterRole == 'Admins') {
            return isCreator || role == 'admin';
          }
          if (_selectedFilterRole == 'Moderators') {
            return role == 'moderator';
          }

          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              if (isCurrentUserAdmin) ...[
                StreamBuilder<QuerySnapshot>(
                  stream: _requestsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final requestDocs = snapshot.data!.docs;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.group_add,
                                  color: Color(0xFFEA580C), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Pending Join Requests (${requestDocs.length})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requestDocs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final reqUid = requestDocs[index].id;
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(reqUid)
                                    .get(),
                                builder: (context, userSnap) {
                                  String reqName = "User";
                                  if (userSnap.hasData &&
                                      userSnap.data!.exists) {
                                    final uData = userSnap.data!.data()
                                        as Map<String, dynamic>?;
                                    reqName = uData?['name'] ??
                                        uData?['displayName'] ??
                                        'User';
                                  }

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        reqName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check_circle,
                                                color: Colors.green, size: 22),
                                            onPressed: () =>
                                                approveMemberRequest(reqUid),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red, size: 22),
                                            onPressed: () =>
                                                rejectMemberRequest(reqUid),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton('All members', setTabState),
                    _buildSegmentButton('Admins', setTabState),
                    _buildSegmentButton('Moderators', setTabState),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setTabState(() => _searchQuery = val.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search members...',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.grey, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF6366F1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune,
                          color: Color(0xFF6366F1), size: 20),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedFilterRole == 'All members') ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('members')
                        .snapshots(),
                    builder: (context, onlineSnap) {
                      int onlineCount = 0;
                      if (onlineSnap.hasData) {
                        onlineCount = onlineSnap.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>?;
                          return data?['isOnline'] == true;
                        }).length;
                      }
                      if (onlineCount == 0) onlineCount = 1;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            assetPath: 'assets/community/a1_profile.png',
                            value: "${memberDocs.length}",
                            label: "",
                            valueColor: Colors.black,
                          ),
                          const _VerticalDivider(),
                          _buildStatColumn(
                            assetPath: 'assets/community/a2_prof.png',
                            iconColor: Colors.orange,
                            value: "$onlineCount",
                            label: "online now",
                            dotColor: Colors.green,
                          ),
                          const _VerticalDivider(),
                          _buildStatColumn(
                            assetPath: 'assets/community/a3_prof.png',
                            value: "${memberDocs.length}",
                            label: "active this week",
                          ),
                          const _VerticalDivider(),
                          _buildStatColumn(
                            assetPath: 'assets/community/a4_prof.png',
                            value: "$newThisWeekCount",
                            label: "new this week",
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              filteredDocs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text("No members match criteria."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final memberDoc = filteredDocs[index];
                        final memberId = memberDoc.id;
                        final memberData =
                            memberDoc.data() as Map<String, dynamic>?;

                        final String customRole = memberData?['role'] ?? '';
                        final Timestamp? joinedAt =
                            memberData?['joinedAt'] as Timestamp?;
                        final bool isCreator = memberId == creatorUid;

                        return GroupMemberCard(
                          uid: memberId,
                          joinedAt: joinedAt,
                          searchFilter: _searchQuery,
                          groupId: widget.groupId,
                          currentGroupCreatorUid: creatorUid,
                          isCreator: isCreator,
                          explicitRole: customRole,
                          isCurrentUserAdmin: isCurrentUserAdmin,
                          onDeletePressed: () =>
                              _showDeleteConfirmationDialog(memberId),
                        );
                      },
                    ),
              if (isCurrentUserAdmin) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF6366F1), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _showAddMemberModal,
                    icon: const Icon(Icons.person_add_alt,
                        color: Color(0xFF6366F1), size: 18),
                    label: const Text(
                      "Invite Members",
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- HELPER BUILDERS ---
  Widget _buildSegmentButton(String title, StateSetter setTabState) {
    final bool isSelected = _selectedFilterRole == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setTabState(() => _selectedFilterRole = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF6366F1) : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    String? assetPath,
    Color? iconColor,
    Color? dotColor,
    required String value,
    required String label,
    Color valueColor = Colors.black,
    double imageWidth = 24.0,
    double imageHeight = 24.0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (assetPath != null) ...[
            Image.asset(
              assetPath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
              color: iconColor,
            ),
            const SizedBox(height: 6),
          ] else if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: valueColor,
                ),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
                color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text,
      {Color iconColor = Colors.grey}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value,
      {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
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
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class GroupMemberCard extends StatelessWidget {
  final String uid;
  final Timestamp? joinedAt;
  final String searchFilter;
  final String groupId;
  final String currentGroupCreatorUid;
  final bool isCreator;
  final String explicitRole;
  final bool isCurrentUserAdmin;
  final VoidCallback onDeletePressed;

  const GroupMemberCard({
    super.key,
    required this.uid,
    this.joinedAt,
    required this.searchFilter,
    required this.groupId,
    required this.currentGroupCreatorUid,
    required this.isCreator,
    required this.explicitRole,
    required this.isCurrentUserAdmin,
    required this.onDeletePressed,
  });

  String _formatJoinDate(Timestamp? timestamp) {
    if (timestamp == null) return "Joined Recently";
    final date = timestamp.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "Joined ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 72,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
          );
        }

        String displayName = "User";
        String displayImage = "";
        String userBio = "No bio provided";
        String username = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            displayName =
                userData['name'] ?? userData['displayName'] ?? "Unnamed User";
            displayImage = userData['imageUrl'] ??
                userData['photoUrl'] ??
                userData['profileImage'] ??
                "";
            username = userData['username'] ?? userData['handle'] ?? '';

            if (userData['bio'] != null &&
                userData['bio'].toString().isNotEmpty) {
              userBio = userData['bio'];
            }
          }
        }

        if (searchFilter.isNotEmpty &&
            !displayName.toLowerCase().contains(searchFilter)) {
          return const SizedBox.shrink();
        }

        String roleLabel = isCreator ? 'Admin' : 'Member';
        if (!isCreator && explicitRole.isNotEmpty) {
          roleLabel = explicitRole;
        }

        final formattedJoinDate = _formatJoinDate(joinedAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEEF2FF),
                backgroundImage:
                    displayImage.isNotEmpty ? NetworkImage(displayImage) : null,
                child: displayImage.isEmpty
                    ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                            fontSize: 16),
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
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (roleLabel == 'Admin' ||
                            roleLabel == 'Moderator') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleLabel == 'Admin'
                                  ? const Color(0xFFEEF2FF)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              roleLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: roleLabel == 'Admin'
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFF059669),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userBio,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formattedJoinDate,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(64, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUid == null || currentUid.isEmpty) {
                    Get.snackbar(
                      "Authentication Required",
                      "Please log in to send messages or friend requests.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  if (currentUid == uid) {
                    Get.snackbar(
                      "Your Profile",
                      "You cannot message yourself.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF6366F1),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    // Check if they are friends
                    final friendDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUid)
                        .collection('friends')
                        .doc(uid)
                        .get();

                    if (friendDoc.exists) {
                      // Already friends -> Navigate directly to ChatScreen
                      final List<String> ids = [currentUid, uid]..sort();
                      final String roomId = ids.join('_');

                      Get.to(() => ChatScreen(
                            roomId: roomId,
                            currentUid: currentUid,
                            friendUid: uid,
                            friendName: displayName,
                            friendInitials: displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            friendAvatarColor: const Color(0xFF6366F1),
                            friendImageUrl: displayImage,
                          ));
                      return;
                    }

                    // Not friends -> Check if request already pending in friend_requests
                    final reqDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('friend_requests')
                        .doc(currentUid)
                        .get();

                    if (reqDoc.exists) {
                      Get.snackbar(
                        "Request Pending",
                        "Friend request already sent to $displayName.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blueAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    // Show confirmation dialog before sending friend request
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text("Add Friend",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Text(
                            "Add $displayName as a friend before Direct messaging."),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              Get.back();
                              try {
                                final currentUserDoc = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(currentUid)
                                    .get();
                                final currentData = currentUserDoc.data()
                                        as Map<String, dynamic>? ??
                                    {};

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .collection('friend_requests')
                                    .doc(currentUid)
                                    .set({
                                  'fromUid': currentUid,
                                  'fromName': currentData['name'] ??
                                      currentData['displayName'] ??
                                      'User',
                                  'fromEmail': currentData['email'] ?? '',
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'status': 'pending',
                                });

                                Get.snackbar(
                                  "Success",
                                  "Friend request sent to $displayName!",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  "Error",
                                  "Failed to send request: $e",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: const Text("Add Friend",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    Get.snackbar(
                      "Error",
                      "Failed to check friendship status: $e",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text(
                  "Message",
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
