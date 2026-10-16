import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/core/di/injection.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/chat_details/chat_details_bloc.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/friends/friends_bloc.dart';
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_2/components/conversation_effects.dart';
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
  /// Owned by this screen: loads room info, photos and documents.
  late final ChatDetailsBloc _details;
  bool _showAllImages = false;
  bool _showAllDocs = false;

  @override
  void initState() {
    super.initState();
    _details = sl<ChatDetailsBloc>()
      ..add(ChatDetailsStarted(
          roomId: widget.roomId, currentUid: widget.currentUid));
  }

  @override
  void dispose() {
    _details.close();
    super.dispose();
  }

  List<SharedDocument> _toSharedDocuments(ChatDetailsState state) => state
      .documents
      .map((d) => SharedDocument(name: d.name, url: d.url, timestamp: d.timestamp))
      .toList();

  void _onBlockTapped(BuildContext context, bool isBlocked) {
    // Result snackbars come from the app-wide FriendsBloc listener.
    final friends = context.read<FriendsBloc>();
    if (isBlocked) {
      friends.add(UserUnblockRequested(
        targetUid: widget.friendUid,
        targetName: widget.friendName,
        roomId: widget.roomId,
      ));
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
                friends.add(UserBlockRequested(widget.friendUid, widget.friendName));
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
    return BlocProvider.value(
      value: _details,
      child: ConversationEffects(
        child: BlocBuilder<FriendsBloc, FriendsState>(
            builder: (context, friends) =>
                BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
                    builder: (context, details) {
      final isBlocked = friends.isBlocked(widget.friendUid);

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
                        lastMessage: details.details?.lastMessage ?? '',
                        createdAt: details.details?.createdAt,
                        roomId: widget.roomId,
                        currentUid: widget.currentUid,
                        isBlocked: isBlocked,
                        onBlock: () => _onBlockTapped(context, isBlocked),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEFEFEF)),
                      const SizedBox(height: 14),
                      !details.imagesLoaded
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : SharedImagesGrid(
                              imageUrls: details.images,
                              showAll: _showAllImages,
                              onToggle: () =>
                                  setState(() => _showAllImages = !_showAllImages),
                            ),
                      const SizedBox(height: 22),
                      !details.documentsLoaded
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : SharedDocumentsList(
                              documents: _toSharedDocuments(details),
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
    }))));
  }
}
