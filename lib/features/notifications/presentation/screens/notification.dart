import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';
import 'package:noteswap/features/community/presentation/pages/community_profile.dart';
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_2/chat_screen.dart';

import '../../domain/model.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => MainPage())) // Pops the current route
            ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  const Text("Something went wrong",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    "No Notifications Yet",
                    style: TextStyle(
                        fontSize: 16,
                        color: theme.disabledColor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromDoc(doc))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              // Formatting the date cleanly (e.g., "Oct 24" or "14:32")
              final date = notification.createdAt?.toDate() ?? DateTime.now();
              final formattedDate = DateFormat('MMM d').format(date);

              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(notification.id)
                            .update({'isRead': true, 'isSeen': true});
                      } catch (_) {}

                      if (notification.groupId != null &&
                          notification.groupId!.isNotEmpty) {
                        Get.to(() => GroupProfilePage(
                              groupId: notification.groupId!,
                            ));
                      } else if (notification.senderId != null &&
                          notification.senderId!.isNotEmpty) {
                        final currentUid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final friendUid = notification.senderId!;
                        final List<String> ids = [currentUid, friendUid]
                          ..sort();
                        final String roomId =
                            notification.chatId ?? ids.join('_');
                        final name =
                            notification.senderName ?? notification.title;

                        Get.to(() => ChatScreen(
                              roomId: roomId,
                              currentUid: currentUid,
                              friendUid: friendUid,
                              friendName: name,
                              friendInitials:
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              friendAvatarColor: const Color(0xFF6366F1),
                            ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom styled icon container
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Notification text details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.hintColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.7),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
