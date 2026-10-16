import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../community/presentation/bloc/membership/membership_bloc.dart';
import '../../Widgets/chatPage.dart';
import '../../domain/repos/chat_repo.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  /// Route with the blocs this page needs (each chat gets fresh ones).
  static Route<void> route({required String groupId, required String groupName}) {
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<ChatBloc>()),
          BlocProvider(create: (_) => sl<MembershipBloc>()),
        ],
        child: ChatPage(groupId: groupId, groupName: groupName),
      ),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String groupImage = "";
  String adminId = "";

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatWatchStarted(widget.groupId));
    loadGroupImage();
  }

  Future<void> loadGroupImage() async {
    final doc = await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data();

      setState(() {
        groupImage = data?["imageUrl"] ?? "";
        adminId = (data?["adminId"] ??
                data?["creatorUid"] ??
                data?["createdBy"] ??
                data?["uid"] ??
                "")
            .toString();
      });
    }
  }

  String get _currentUserId {
    final authState = context.read<AuthBloc>().state;
    return authState is Authenticated ? authState.user.uid : '';
  }

  /// Result arrives in the MembershipBloc listener in [build].
  void leaveGroup() {
    context.read<MembershipBloc>().add(MembershipLeavePressed(
          groupId: widget.groupId,
          groupName: widget.groupName,
          userId: _currentUserId,
        ));
  }

  Future<void> showLeaveDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Leave Group",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1E),
          ),
        ),
        content: const Text(
          "Are you sure you want to leave this group?",
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Leave",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      leaveGroup();
    }
  }

  void _sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    context
        .read<ChatBloc>()
        .add(ChatTextSent(groupId: widget.groupId, text: text));

    controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId;

    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (p, c) => p.actionErrorId != c.actionErrorId,
          listener: (context, state) => _showSnack(state.actionError),
        ),
        BlocListener<MembershipBloc, MembershipState>(
          listenWhen: (p, c) => p.outcomeId != c.outcomeId,
          listener: (context, state) {
            final outcome = state.outcome!;
            if (outcome.isError) {
              _showSnack('Failed to leave group: ${outcome.message}');
            } else {
              _showSnack('Left group successfully');
              Navigator.pop(context);
            }
          },
        ),
      ],
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatAppBar(
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupImage: groupImage,
        onLeave: showLeaveDialog,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ChatMessageList(
                groupId: widget.groupId,
                scrollController: scrollController,
                adminId: adminId,
                currentUserId: currentUserId,
              ),
            ),
            ChatInputBar(
              controller: controller,
              onSend: _sendMessage,
              onPickImage: () => _pickAndSend(MediaKind.image),
              onPickVideo: () => _pickAndSend(MediaKind.video),
              onPickDocument: () => _pickAndSend(MediaKind.document),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static const _documentExtensions = [
    'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'zip', 'rar',
  ];

  /// Picking a file is UI work (system dialog); compressing/uploading it is
  /// done by the data layer through ChatBloc.
  Future<void> _pickAndSend(MediaKind kind) async {
    ChatAttachment? file;
    switch (kind) {
      case MediaKind.image:
      case MediaKind.video:
        final picker = ImagePicker();
        final picked = kind == MediaKind.image
            ? await picker.pickImage(source: ImageSource.gallery)
            : await picker.pickVideo(source: ImageSource.gallery);
        if (picked != null) {
          file = ChatAttachment(path: picked.path, name: picked.name);
        }
      case MediaKind.document:
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: _documentExtensions,
        );
        final picked = result?.files.single;
        if (picked?.path != null) {
          file = ChatAttachment(
            path: picked!.path!,
            name: picked.name,
            extension: picked.extension,
          );
        }
    }
    if (file == null || !mounted) return; // user cancelled
    context
        .read<ChatBloc>()
        .add(ChatMediaSent(groupId: widget.groupId, kind: kind, file: file));
  }
}
