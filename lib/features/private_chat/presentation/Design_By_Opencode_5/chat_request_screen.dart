import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/friends/friends_bloc.dart';
import 'chat_request_model.dart';
import 'chat_request_components.dart';

/// Incoming and ignored friend requests. Data and actions come from the
/// app-wide FriendsBloc; result snackbars are shown by its listener.
class ChatRequestScreen extends StatelessWidget {
  final String searchQuery;

  const ChatRequestScreen({super.key, this.searchQuery = ''});

  List<ChatRequest> _filterByName(List<ChatRequest> requests) {
    final query = searchQuery.toLowerCase();
    if (query.isEmpty) return requests;
    return requests
        .where((r) => r.fromName.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      buildWhen: (p, c) =>
          p.incomingRequests != c.incomingRequests ||
          p.ignoredRequests != c.ignoredRequests,
      builder: (context, friends) {
        final incoming = _filterByName(
            friends.incomingRequests.map(ChatRequest.fromEntity).toList());
        final ignored = _filterByName(
            friends.ignoredRequests.map(ChatRequest.fromEntity).toList());

        if (incoming.isEmpty && ignored.isEmpty) {
          return const EmptyRequestsView();
        }

        final bloc = context.read<FriendsBloc>();
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (incoming.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SectionLabel(title: 'INCOMING REQUESTS'),
                ),
                const SizedBox(height: 4),
                ...incoming.map((request) => IncomingRequestCard(
                      request: request,
                      onAccept: () => bloc.add(FriendRequestAccepted(request)),
                      onDecline: () =>
                          bloc.add(FriendRequestDeclined(request)),
                    )),
              ],
              if (ignored.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SectionLabel(title: 'IGNORED'),
                ),
                const SizedBox(height: 4),
                ...ignored.map((request) => IgnoredRequestCard(
                      request: request,
                      onAccept: () => bloc.add(IgnoredRequestAccepted(request)),
                    )),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
