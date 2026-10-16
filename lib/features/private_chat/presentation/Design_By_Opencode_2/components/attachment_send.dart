import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/navigation/app_navigator.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/private_chat_repository.dart';
import '../../bloc/conversation/conversation_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../common_widgets.dart';

/// Shared by the photo and document preview screens: shows a loader, asks
/// the conversation to upload + send, and closes the preview when done.
/// Failures close only the loader and show the error.
class AttachmentSendListener extends StatelessWidget {
  final Widget child;
  const AttachmentSendListener({super.key, required this.child});

  /// Called by the preview's send button.
  static void send(
    BuildContext context, {
    required String path,
    required String name,
    required MessageType type,
    required String friendUid,
  }) {
    AppNavigator.showAppDialog(
      const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      barrierDismissible: false,
    );
    context.read<ConversationBloc>().add(ConversationAttachmentSent(
          file: LocalAttachment(path: path, name: name),
          type: type,
          friendIsBlocked: context.read<FriendsBloc>().state.isBlocked(friendUid),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listenWhen: (p, c) =>
          p.uploadId != c.uploadId &&
          (c.uploadStatus == UploadStatus.done ||
              c.uploadStatus == UploadStatus.failed),
      listener: (context, state) {
        if (state.uploadStatus == UploadStatus.done) {
          AppNavigator.popTimes(2); // loader + preview screen
        } else {
          AppNavigator.pop(); // loader only; the user can retry
          showErrorSnackbar(state.error);
        }
      },
      child: child,
    );
  }
}
