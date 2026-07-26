import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';
import 'package:noteswap/features/private_chat/data/private-chat-services/user_friend_add.dart';
import '../common_widgets.dart';
import 'chat_details_model.dart';
import 'chat_details_components.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String roomId;
  final String currentUid;
  final String friendUid;
  final String friendName;
  final String friendInitials;
  final Color friendAvatarColor;
  final bool isOnline;

  const ChatDetailsScreen({
    super.key,
    required this.roomId,
    required this.currentUid,
    required this.friendUid,
    required this.friendName,
    required this.friendInitials,
    required this.friendAvatarColor,
    required this.isOnline,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final ChatController _chatController = Get.find<ChatController>();
  late final UserController _userController;

  List<String> _imageUrls = [];
  List<SharedDocument> _docs = [];
  bool _isLoadingImages = true;
  bool _isLoadingDocs = true;
  bool _showAllImages = false;
  bool _showAllDocs = false;
  String _lastMessage = '';
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>();
    _loadImages();
    _loadDocs();
    _loadRoomInfo();
  }

  Future<void> _loadRoomInfo() async {
    final info = await _chatController.getRoomInfo(widget.roomId, widget.currentUid);
    if (mounted) {
      setState(() {
        _lastMessage = info['lastMessage'] as String? ?? '';
        _createdAt = (info['createdAt'] as dynamic)?.toDate();
      });
    }
  }

  Future<void> _loadImages() async {
    final urls = await _chatController.fetchAllImagesForRoom(widget.roomId);
    if (mounted) {
      setState(() {
        _imageUrls = urls;
        _isLoadingImages = false;
      });
    }
  }

  Future<void> _loadDocs() async {
    final docsData = await _chatController.fetchAllDocsForRoom(widget.roomId);
    if (mounted) {
      setState(() {
        _docs = docsData
            .map((d) => SharedDocument(
                  name: d['name'] as String? ?? 'Unknown',
                  url: d['url'] as String? ?? '',
                  timestamp: d['timestamp'] as DateTime? ?? DateTime.now(),
                ))
            .toList();
        _isLoadingDocs = false;
      });
    }
  }

  void _onBlockTapped(BuildContext context, bool isBlocked) {
    if (isBlocked) {
      final ids = [widget.currentUid, widget.friendUid]..sort();
      final roomId = ids.join('_');
      _userController.unblockUser(widget.friendUid, roomId);
      showSuccessSnackbar('${widget.friendName} has been unblocked');
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF6139ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Block User',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to block ${widget.friendName}? You won\'t receive notifications from them.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _userController.blockUser(widget.friendUid);
                showSuccessSnackbar('${widget.friendName} has been blocked');
              },
              child: const Text(
                'Block',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isBlocked = _userController.blockedUids.contains(widget.friendUid);

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ChatDetailsAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      ProfileHeader(
                        name: widget.friendName,
                        initials: widget.friendInitials,
                        avatarColor: widget.friendAvatarColor,
                        isOnline: widget.isOnline,
                        statusText: widget.isOnline ? 'Active now' : '',
                      ),
                      const SizedBox(height: 28),
                      QuickActionsRow(
                        friendUid: widget.friendUid,
                        friendName: widget.friendName,
                        lastMessage: _lastMessage,
                        createdAt: _createdAt,
                        roomId: widget.roomId,
                        currentUid: widget.currentUid,
                        isBlocked: isBlocked,
                        onBlock: () => _onBlockTapped(context, isBlocked),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEFEFEF)),
                      const SizedBox(height: 14),
                      _isLoadingImages
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : SharedImagesGrid(
                              imageUrls: _imageUrls,
                              showAll: _showAllImages,
                              onToggle: () =>
                                  setState(() => _showAllImages = !_showAllImages),
                            ),
                      const SizedBox(height: 22),
                      _isLoadingDocs
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : SharedDocumentsList(
                              documents: _docs,
                              showAll: _showAllDocs,
                              onToggle: () =>
                                  setState(() => _showAllDocs = !_showAllDocs),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
