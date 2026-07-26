import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/private_chat/data/private-chat-services/user_friend_add.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';
import 'presentation/Design_By_Opencode_3/directory_screen.dart';
import 'presentation/Design_By_Opencode_5/chat_request_screen.dart';
import 'presentation/Design_By_Opencode/recent_chats_screen.dart';
import 'package:noteswap/features/events/notifications/notifications_screen.dart';
import 'package:noteswap/features/events/announcements/announcements_screen.dart';

class PrivateChatPageController extends StatefulWidget {
  const PrivateChatPageController({Key? key}) : super(key: key);

  @override
  _PrivateChatPageControllerState createState() =>
      _PrivateChatPageControllerState();
}

class _PrivateChatPageControllerState extends State<PrivateChatPageController> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    Get.put(ChatController());
    Get.put(UserController());
  }

  void logout() {
    final authCubit = context.read<AuthCubit>();
    authCubit.logout();
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF6139ED), size: 22),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _page == index;
    return GestureDetector(
      onTap: () => setState(() => _page = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }

  String get _title {
    switch (_page) {
      case 0:
        return 'Find Friends';
      case 1:
        return 'Get Request';
      case 2:
        return 'Chat With Them';
      default:
        return 'Chat With\n Friends';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Quicksand'),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6139ED),
                      Color.fromARGB(255, 221, 220, 224),
                      Color.fromARGB(255, 221, 220, 224).withValues(alpha: 0.8),
                      Color.fromARGB(255, 221, 220, 224).withValues(alpha: 0.8),
                      // Color.fromARGB(255, 221, 220, 224).withValues(alpha: 0.4),
                      // Color.fromARGB(255, 221, 220, 224).withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 30,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: 0,
                              ),
                            ),
                            Row(
                              children: [
                                _buildHeaderIcon(
                                  Icons.notifications,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const NotificationsScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildHeaderIcon(
                                  Icons.calendar_today,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AnnouncementsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTab('Message', 0),
                            _buildTab('Requests', 1),
                            _buildTab('Friends', 2),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        child: Stack(
                          children: [
                            IndexedStack(
                              index: _page,
                              children: [
                                DirectoryScreen(
                                    onGoToRequests: () =>
                                        setState(() => _page = 1)),
                                const ChatRequestScreen(),
                                const RecentChatsScreen(),
                              ],
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: GestureDetector(
                                onTap: logout,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
