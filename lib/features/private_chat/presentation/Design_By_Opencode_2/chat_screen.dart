import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/core/di/injection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/friends/friends_bloc.dart';
import 'package:noteswap/features/private_chat/domain/entities/chat_message.dart'
    as domain;
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_2/components/component_media_dialog_box.dart';
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_2/components/conversation_effects.dart';
import 'package:noteswap/features/private_chat/presentation/Design_By_Opencode_4/chat_details_screen.dart';
import '../common_widgets.dart';
import 'widgets/chat_header.dart';
import 'widgets/pinned_message_widget.dart';
import 'widgets/date_separator.dart';
import 'widgets/receiver_text_bubble.dart';
import 'widgets/sender_text_bubble.dart';
import 'widgets/image_message_bubble.dart';
import 'widgets/file_message_card.dart';
import 'widgets/message_input_bar.dart';
import 'widgets/message_context_bottom_sheet.dart';
import 'models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String currentUid;
  final String friendUid;
  final String friendName;
  final String friendInitials;
  final Color friendAvatarColor;
  final String? friendImageUrl;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.currentUid,
    required this.friendUid,
    required this.friendName,
    required this.friendInitials,
    required this.friendAvatarColor,
    this.friendImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Owned by this screen: created on open, closed on leave.
  late final ConversationBloc _conversation;
  final TextEditingController _messageController = TextEditingController();
  domain.ChatMessage? _replyMessage;
  late final ComponentMediaDialog _mediaDialog;

  @override
  void initState() {
    super.initState();
    _conversation = sl<ConversationBloc>()
      ..add(ConversationStarted(
        roomId: widget.roomId,
        currentUid: widget.currentUid,
        friendUid: widget.friendUid,
      ));
    _mediaDialog = ComponentMediaDialog(
      targetUser: widget.friendUid,
      conversation: _conversation,
    );
  }

  void _openChatDetails() {
    // Details shares this conversation (for the Call button).
    AppNavigator.push(BlocProvider.value(
      value: _conversation,
      child: ChatDetailsScreen(
          roomId: widget.roomId,
          currentUid: widget.currentUid,
          friendUid: widget.friendUid,
          friendName: widget.friendName,
          friendInitials: widget.friendInitials,
          friendAvatarColor: widget.friendAvatarColor,
          isOnline: _conversation.state.friendOnline,
        ),
    ));
  }

  Future<void> _openDocument(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _conversation.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _conversation.add(ConversationTextSent(
      text: _messageController.text,
      replyTo: _replyMessage,
      replyToSenderLabel: _replyMessage?.senderId == widget.currentUid
          ? 'You'
          : widget.friendName,
      friendIsBlocked:
          context.read<FriendsBloc>().state.isBlocked(widget.friendUid),
    ));
    _messageController.clear();
    setState(() => _replyMessage = null);
  }

  void _unblockUser() {
    // The result snackbar comes from the app-wide FriendsBloc listener.
    context.read<FriendsBloc>().add(UserUnblockRequested(
          targetUid: widget.friendUid,
          targetName: widget.friendName,
          roomId: widget.roomId,
        ));
  }

  /// Looks up the number; [ConversationEffects] opens the dialer.
  void _voiceCall() => _conversation.add(const ConversationCallRequested());

  void _videoCall() {
    showInfoSnackbar('Video call coming soon');
  }

  void _showContextMenu(domain.ChatMessage msg) {
    MessageContextBottomSheet.show(
      context: context,
      messageText: msg.message,
      onReply: () => setState(() => _replyMessage = msg),
      onPin: () => _conversation.add(ConversationMessagePinned(msg)),
      onDelete: () => _conversation.add(ConversationMessageDeleted(msg)),
      onReact: (emoji) =>
          _conversation.add(ConversationReactionToggled(msg, emoji)),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _conversation,
      child: ConversationEffects(
        child: Scaffold(
      backgroundColor: const Color(0xFF5A48E6),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: const Color(0xFF5A48E6),
            ),
            Column(
              children: [
                BlocBuilder<ConversationBloc, ConversationState>(
                  buildWhen: (p, c) => p.friendOnline != c.friendOnline,
                  builder: (context, state) => ChatHeader(
                      name: widget.friendName,
                      initials: widget.friendInitials,
                      avatarColor: widget.friendAvatarColor,
                      isOnline: state.friendOnline,
                      imageUrl: widget.friendImageUrl,
                      onTap: _openChatDetails,
                      onVideoCall: _videoCall,
                      onVoiceCall: _voiceCall,
                      onInfo: _openChatDetails,
                    )),
                BlocBuilder<ConversationBloc, ConversationState>(
                    buildWhen: (p, c) => p.pinned != c.pinned,
                    builder: (context, state) {
                  final pinned = state.visiblePin;
                  if (pinned == null) {
                    return const SizedBox.shrink();
                  }
                  return PinnedMessageWidget(
                    message: pinned.pinnedMessageContent,
                    onClose: () =>
                        _conversation.add(const ConversationUnpinned()),
                  );
                }),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF5A48E6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: BlocBuilder<ConversationBloc, ConversationState>(
                        buildWhen: (p, c) => p.messages != c.messages,
                        builder: (context, state) {
                        final msgs = state.messages;
                        if (msgs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF999999),
                              ),
                            ),
                          );
                        }

                        final displayList = <dynamic>[];
                        String? lastDate;

                        for (final msg in msgs) {
                          final dateStr = _formatDateLabel(msg.timestamp);
                          if (dateStr != lastDate) {
                            displayList.add(dateStr);
                            lastDate = dateStr;
                          }
                          displayList.add(msg);
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            if (item is String) {
                              return DateSeparator(label: item);
                            }

                            final msg = item as domain.ChatMessage;
                            final isSender =
                                msg.senderId == widget.currentUid;
                            final time = _formatTime(msg.timestamp);

                            final replyContent = msg.repliedMessageContent;
                            final replySender = msg.repliedMessageSender;
                            final replyType = msg.repliedMessageType;
                            final reactions = msg.reactions;

                            switch (msg.type) {
                              case domain.MessageType.text:
                                if (isSender) {
                                  return SenderTextBubble(
                                    message: msg.message,
                                    timestamp: time,
                                    onLongPress: () =>
                                        _showContextMenu(msg),
                                    repliedMessageContent: replyContent,
                                    repliedMessageSender: replySender,
                                    repliedMessageType: replyType,
                                    reactions: reactions,
                                    currentUserId: widget.currentUid,
                                  );
                                } else {
                                  return ReceiverTextBubble(
                                    message: msg.message,
                                    timestamp: time,
                                    onLongPress: () =>
                                        _showContextMenu(msg),
                                    repliedMessageContent: replyContent,
                                    repliedMessageSender: replySender,
                                    repliedMessageType: replyType,
                                    reactions: reactions,
                                    currentUserId: widget.currentUid,
                                  );
                                }
                              case domain.MessageType.image:
                                return ImageMessageBubble(
                                  timestamp: time,
                                  imageUrl: msg.imageUrl ?? '',
                                  isSender: isSender,
                                  onLongPress: () =>
                                      _showContextMenu(msg),
                                  repliedMessageContent: replyContent,
                                  repliedMessageSender: replySender,
                                  repliedMessageType: replyType,
                                  reactions: reactions,
                                  currentUserId: widget.currentUid,
                                );
                              case domain.MessageType.doc:
                              case domain.MessageType.video:
                                return FileMessageCard(
                                  fileName:
                                      msg.docUrl?.split('/').last ?? 'File',
                                  fileSize: '',
                                  timestamp: time,
                                  isSender: isSender,
                                  onTap: () => _openDocument(msg.docUrl),
                                  onLongPress: () =>
                                      _showContextMenu(msg),
                                  repliedMessageContent: replyContent,
                                  repliedMessageSender: replySender,
                                  repliedMessageType: replyType,
                                  reactions: reactions,
                                  currentUserId: widget.currentUid,
                                );
                            }
                          },
                        );
                      }),
                    ),
                  ),
                ),
                BlocBuilder<FriendsBloc, FriendsState>(
                    builder: (context, friends) {
                  final isBlocked = friends.isBlocked(widget.friendUid);
                  if (isBlocked) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.block,
                              color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'You blocked this user',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _unblockUser,
                            child: const Text(
                              'Unblock',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return MessageInputBar(
                    controller: _messageController,
                    onSend: _sendMessage,
                    onAttach: () =>
                        _mediaDialog.showMediaOptions(context),
                    replyMessage: _replyMessage != null
                        ? _uiChatMessageFromDomain(_replyMessage!)
                        : null,
                    onCancelReply: () =>
                        setState(() => _replyMessage = null),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  ChatMessage _uiChatMessageFromDomain(domain.ChatMessage msg) {
    ChatMessageType uiType;
    switch (msg.type) {
      case domain.MessageType.image:
        uiType = ChatMessageType.image;
        break;
      case domain.MessageType.doc:
      case domain.MessageType.video:
        uiType = ChatMessageType.file;
        break;
      default:
        uiType = ChatMessageType.text;
    }
    return ChatMessage(
      type: uiType,
      isSender: msg.senderId == widget.currentUid,
      text: msg.message,
      timestamp: _formatTime(msg.timestamp),
      imageUrl: msg.imageUrl ?? '',
      fileName: msg.docUrl?.split('/').last,
      fileSize: '',
    );
  }
}
