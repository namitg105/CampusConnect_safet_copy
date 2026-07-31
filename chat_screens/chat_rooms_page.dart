import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/chat/domain/entities/chat_room_entity.dart';
import 'package:noteswap/features/chat/presentation/pages/chat_room_page.dart';
import 'package:noteswap/features/chat/presentation/pages/create_chat_room_page.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class ChatRoomsPage extends StatefulWidget {
  final AppUser currentUser;

  const ChatRoomsPage({super.key, required this.currentUser});

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  String query = '';

  late final List<ChatRoomEntity> allRooms = [
    ChatRoomEntity(
      id: 'room_aiml',
      name: 'AI & ML Society',
      collegeId: widget.currentUser.collegeId,
      participants: [
        widget.currentUser.uid,
        'user1',
        'user2',
        'user3',
        'user4',
        'user5'
      ],
      lastMessage: 'Vicky is typing...',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ChatRoomEntity(
      id: 'room1',
      name: 'Study Group',
      collegeId: widget.currentUser.collegeId,
      participants: [widget.currentUser.uid, 'user1', 'user2'],
      lastMessage: 'Review session at 5 PM?',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 6)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ChatRoomEntity(
      id: 'room2',
      name: 'Events Crew',
      collegeId: widget.currentUser.collegeId,
      participants: [widget.currentUser.uid, 'user3', 'user4'],
      lastMessage: 'Promo posters are ready!',
      lastUpdated:
          DateTime.now().subtract(const Duration(hours: 1, minutes: 22)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ChatRoomEntity(
      id: 'room3',
      name: 'Project Help',
      collegeId: widget.currentUser.collegeId,
      participants: [widget.currentUser.uid, 'user5'],
      lastMessage: 'Can someone share the notes?',
      lastUpdated:
          DateTime.now().subtract(const Duration(hours: 3, minutes: 14)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<ChatRoomEntity> get filteredRooms {
    if (query.trim().isEmpty) return allRooms;
    return allRooms
        .where((room) => room.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final LightModeController lightModeController =
        Get.find<LightModeController>();

    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;

      final backgroundColor =
          isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
      final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
      final subTextColor =
          isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);
      final brandColor = const Color(0xFF6139ED);

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: cardColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Chat Rooms',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_comment_outlined, color: brandColor),
              onPressed: () {
                Get.to(
                    () => CreateChatRoomPage(currentUser: widget.currentUser));
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // Search input block
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isLightMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                  border: Border.all(
                    color: isLightMode ? Colors.grey[100]! : Colors.grey[850]!,
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => query = value),
                  style: TextStyle(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(
                      color: subTextColor.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: subTextColor,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Rooms list
              Expanded(
                child: filteredRooms.isEmpty
                    ? Center(
                        child: Text(
                          'No chat rooms available.',
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: _ChatRoomTile(
                              room: room,
                              onTap: () {
                                Get.to(() => ChatRoomPage(
                                      currentUser: widget.currentUser,
                                      chatRoom: room,
                                    ));
                              },
                              isLightMode: isLightMode,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              cardColor: cardColor,
                              brandColor: brandColor,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomEntity room;
  final VoidCallback onTap;
  final bool isLightMode;
  final Color textColor;
  final Color subTextColor;
  final Color cardColor;
  final Color brandColor;

  const _ChatRoomTile({
    required this.room,
    required this.onTap,
    required this.isLightMode,
    required this.textColor,
    required this.subTextColor,
    required this.cardColor,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    final isAiml = room.id == 'room_aiml';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLightMode
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: isLightMode ? Colors.grey[100]! : Colors.grey[850]!,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Custom avatar with logo for AI & ML, fallback for others
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isAiml
                  ? Image.asset(
                      'assets/chat_assets/image 60.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 44,
                          height: 44,
                          color: brandColor,
                          child: const Center(
                            child: Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      color: brandColor.withValues(alpha: 0.08),
                      child: Center(
                        child: Text(
                          room.name.isNotEmpty
                              ? room.name[0].toUpperCase()
                              : 'C',
                          style: TextStyle(
                            color: brandColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    room.lastMessage,
                    style: TextStyle(
                      color: isAiml ? brandColor : subTextColor,
                      fontSize: 12,
                      fontWeight: isAiml ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isAiml
                      ? "10:04 AM"
                      : "${room.lastUpdated.hour.toString().padLeft(2, '0')}:${room.lastUpdated.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(color: subTextColor, fontSize: 11),
                ),
                const SizedBox(height: 8),
                if (isAiml)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: brandColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
