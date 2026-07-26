import 'package:flutter/material.dart';
import 'chat_request_model.dart';

class ChatRequestHeader extends StatelessWidget {
  const ChatRequestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            'Chat Requests',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String title;
  const SectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: const Color(0xFFB0B0B0),
        ),
      ),
    );
  }
}

class RequestAvatar extends StatelessWidget {
  final ChatRequest request;
  const RequestAvatar({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final hasImage = request.fromImageURL.isNotEmpty;

    return CircleAvatar(
      radius: 24,
      backgroundColor: request.avatarColor,
      backgroundImage: hasImage ? NetworkImage(request.fromImageURL) : null,
      child: hasImage
          ? null
          : Text(
              request.initials,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
    );
  }
}

class AcceptButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const AcceptButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 34,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE5F7EF),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          'Accept',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F9E77),
          ),
        ),
      ),
    );
  }
}

class DeclineButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const DeclineButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 34,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          'Decline',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9A9A9A),
          ),
        ),
      ),
    );
  }
}

class PendingBadge extends StatelessWidget {
  const PendingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Text(
        'Pending',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFD4A017),
        ),
      ),
    );
  }
}

class IncomingRequestCard extends StatelessWidget {
  final ChatRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const IncomingRequestCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          RequestAvatar(request: request),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.fromName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.timeAgo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AcceptButton(onPressed: onAccept),
          const SizedBox(width: 8),
          DeclineButton(onPressed: onDecline),
        ],
      ),
    );
  }
}

class SentRequestCard extends StatelessWidget {
  final ChatRequest request;
  const SentRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          RequestAvatar(request: request),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.fromName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.timeAgo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const PendingBadge(),
        ],
      ),
    );
  }
}

class EmptyRequestsView extends StatelessWidget {
  const EmptyRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: 48,
              color: Color(0xFFDADADA),
            ),
            const SizedBox(height: 12),
            Text(
              'No pending requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IgnoredRequestCard extends StatelessWidget {
  final ChatRequest request;
  final VoidCallback? onAccept;

  const IgnoredRequestCard({
    super.key,
    required this.request,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          RequestAvatar(request: request),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.fromName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.timeAgo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AcceptButton(onPressed: onAccept),
        ],
      ),
    );
  }
}
