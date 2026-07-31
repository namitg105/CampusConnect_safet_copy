import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/private_chat/data/private-chat-services/user_friend_add.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';
import 'presentation/Design_By_Opencode_3/directory_screen.dart';
import 'presentation/Design_By_Opencode_5/chat_request_screen.dart';
import 'presentation/Design_By_Opencode/recent_chats_screen.dart';
import 'presentation/Design_By_Opencode/recent_chats_components.dart';
import 'package:noteswap/features/events/announcements/announcements_screen.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';
import 'package:noteswap/features/profile/presentation/pages/profile_settings_page.dart';

class PrivateChatPageController extends StatefulWidget {
  const PrivateChatPageController({Key? key}) : super(key: key);

  @override
  _PrivateChatPageControllerState createState() =>
      _PrivateChatPageControllerState();
}

class _PrivateChatPageControllerState extends State<PrivateChatPageController> {
  late TextEditingController _searchController;
  UserController? _userController;
  int _selectedTab = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController(), permanent: true);
    }
    if (!Get.isRegistered<UserController>()) {
      Get.put(UserController(), permanent: true);
    }
    _userController = Get.find<UserController>();
    if (Get.isRegistered<MainPageController>()) {
      _selectedTab =
          Get.find<MainPageController>().privateChatSelectedTab.value;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void logout() {
    final authCubit = context.read<AuthCubit>();
    authCubit.logout();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query.trim());
  }

  void _onTabSelected(int index) {
    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().privateChatSelectedTab.value = index;
    }
    setState(() => _selectedTab = index);
  }

  void _switchToRequestTab() {
    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().privateChatSelectedTab.value = 2;
    }
    setState(() => _selectedTab = 2);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Quicksand'),
      child: Obx(() {
        if (Get.isRegistered<MainPageController>()) {
          _selectedTab =
              Get.find<MainPageController>().privateChatSelectedTab.value;
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FC),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Divider(
                    height: 1, thickness: 1, color: const Color(0xFFECECEC)),
                ChatsTabBar(
                  selectedIndex: _selectedTab,
                  onTabSelected: _onTabSelected,
                ),
                Divider(
                    height: 1, thickness: 1, color: const Color(0xFFECECEC)),
                SearchPeopleBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
                Obx(() {
                  final friendsCount = _userController?.friendsList.length ?? 0;
                  final onlineCount = _getOnlineCount();
                  final blockedCount = _userController?.blockedUids.length ?? 0;
                  return ChatStatisticsCard(
                    friendsCount: friendsCount,
                    onlineCount: onlineCount,
                    blockedCount: blockedCount,
                  );
                }),
                const SizedBox(height: 8),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      RecentChatsScreen(
                        searchQuery: _searchQuery,
                        selectedTab: 0,
                      ),
                      RecentChatsScreen(
                        searchQuery: _searchQuery,
                        selectedTab: 1,
                      ),
                      ChatRequestScreen(
                        searchQuery: _searchQuery,
                      ),
                      DirectoryScreen(
                        searchQuery: _searchQuery,
                        onGoToRequests: _switchToRequestTab,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  int _getOnlineCount() {
    return _userController?.friendStatuses.values
            .where((v) => v == true)
            .length ??
        0;
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final friendsCount = _userController?.friendsList.length ?? 0;
                  final onlineCount = _getOnlineCount();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$friendsCount friends',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$onlineCount Online',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          ProfileAvatarButton(
            onTap: () => Get.to(() => const ProfileSettingsPage()),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
