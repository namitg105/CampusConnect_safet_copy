import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/conversation/conversation_bloc.dart';
import '../../common_widgets.dart';

/// One-off reactions to [ConversationBloc]: error snackbars and opening the
/// phone dialer. Used by the chat screen and the chat details screen.
class ConversationEffects extends StatelessWidget {
  final Widget child;
  const ConversationEffects({super.key, required this.child});

  static Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbar('Could not launch dialer');
    }
  }

  /// Chat details opens on top of the chat screen with the same bloc;
  /// only the visible (top) screen reacts, so nothing happens twice.
  static bool _isTop(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent ?? true;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConversationBloc, ConversationState>(
          listenWhen: (p, c) => p.errorId != c.errorId && _isTop(context),
          listener: (context, state) => showErrorSnackbar(state.error),
        ),
        BlocListener<ConversationBloc, ConversationState>(
          listenWhen: (p, c) => p.dialId != c.dialId && _isTop(context),
          listener: (context, state) => _dial(state.dialNumber!),
        ),
      ],
      child: child,
    );
  }
}
