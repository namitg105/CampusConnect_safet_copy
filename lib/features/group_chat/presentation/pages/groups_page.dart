import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteswap/features/group_chat/presentation/pages/group_chat.dart';
import '../../../group_chat/presentation/pages/new_group.dart';

class GroupsDisplayPage extends StatefulWidget {
  const GroupsDisplayPage({super.key});

  @override
  State<GroupsDisplayPage> createState() => _GroupsDisplayPageState();
}

class _GroupsDisplayPageState extends State<GroupsDisplayPage> {
  void _navigateToNewGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewGroupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF6366F1);
    const Color textDark = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);
    const Color bgSurface = Color(0xFFF8FAFC);

    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: bgSurface,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: brandPrimary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToNewGroup(context),
            backgroundColor: brandPrimary,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 18, // Reduced icon size
            ),
            label: const Text(
              "New Chat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12, // Reduced from 14
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            collapsedHeight: 70,
            backgroundColor: Colors.white.withOpacity(0.9),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(color: Colors.white.withOpacity(0.5)),
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  centerTitle: false,
                  title: const SafeArea(
                    bottom: false,
                    child: Text(
                      "Conversations",
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20, // Reduced from 24
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('group_chats')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: CircularProgressIndicator(color: brandPrimary)),
                );
              }

              if (snapshot.hasError) {
                return _buildEmptyState(
                  Icons.error_outline_rounded,
                  "Database Connection Error",
                  "Details: ${snapshot.error}",
                  Colors.redAccent,
                );
              }

              if (currentUserId.isEmpty) {
                return _buildEmptyState(
                  Icons.lock_outline_rounded,
                  "Authentication Required",
                  "Please log into your account to check messages.",
                  textMuted,
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(
                  Icons.folder_open_rounded,
                  "No Groups Found",
                  "The 'group_chats' collection appears to be empty.",
                  textMuted,
                );
              }

              final allDocs = snapshot.data!.docs;
              final cleanUserId = currentUserId.trim();

              final filteredDocs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data == null) return false;

                final String createdBy =
                    (data['createdBy'] ?? '').toString().trim();
                if (createdBy == cleanUserId) return true;

                if (data.containsKey('members')) {
                  final membersData = data['members'];

                  if (membersData is List) {
                    return membersData
                        .map((e) => e.toString().trim())
                        .contains(cleanUserId);
                  } else if (membersData is Map) {
                    return membersData.values
                        .map((e) => e.toString().trim())
                        .contains(cleanUserId);
                  }
                }

                return false;
              }).toList();

              if (filteredDocs.isEmpty) {
                return _buildEmptyState(
                  Icons.person_search_rounded,
                  "No Active Conversations",
                  "You haven't been added to any conversations yet.",
                  textMuted,
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final docData =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final String groupId = filteredDocs[index].id;
                      final String groupName =
                          docData['name'] ?? 'Unnamed Group';
                      final String imageUrl = docData['imageUrl'] ?? '';
                      final String description = docData['description'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ActiveChatCard(
                          groupId: groupId,
                          groupName: groupName,
                          imageUrl: imageUrl,
                          description: description,
                          brandPrimary: brandPrimary,
                        ),
                      );
                    },
                    childCount: filteredDocs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      IconData icon, String title, String subtitle, Color color) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02), blurRadius: 20)
                ],
              ),
              child: Icon(icon, size: 40, color: color.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 15, // Reduced from 18
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, // Reduced from 14
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChatCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String imageUrl;
  final String description;
  final Color brandPrimary;

  const _ActiveChatCard({
    required this.groupId,
    required this.groupName,
    required this.imageUrl,
    required this.description,
    required this.brandPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ChatPage(groupId: groupId, groupName: groupName)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: brandPrimary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: imageUrl.trim().isEmpty
                        ? Icon(Icons.groups_rounded,
                            color: brandPrimary, size: 24)
                        : Image.network(
                            imageUrl.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.groups_rounded,
                                color: brandPrimary,
                                size: 24),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              groupName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13, // Reduced from 15
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Active",
                            style: TextStyle(
                              fontSize: 10, // Reduced from 11
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Nested Real-time Last Message Fetcher Node
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('group_chats')
                            .doc(groupId)
                            .collection('messages')
                            .orderBy('sentAt', descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, msgSnapshot) {
                          String displayText = description.isNotEmpty
                              ? description
                              : "Tap to view conversation...";

                          if (msgSnapshot.hasData &&
                              msgSnapshot.data!.docs.isNotEmpty) {
                            final lastMsgData = msgSnapshot.data!.docs.first
                                .data() as Map<String, dynamic>;
                            final senderName = lastMsgData['senderName'] ?? '';
                            final msgBody = lastMsgData['message'] ?? '';
                            displayText = senderName.isNotEmpty
                                ? "$senderName: $msgBody"
                                : msgBody;
                          }

                          return Text(
                            displayText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11, // Reduced from 13
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: brandPrimary,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
