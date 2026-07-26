import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/private-chat-services/user_friend_add.dart';
import '../common_widgets.dart';
import 'chat_request_model.dart';
import 'chat_request_components.dart';

class ChatRequestScreen extends StatefulWidget {
  const ChatRequestScreen({super.key});

  @override
  State<ChatRequestScreen> createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  late UserController _userController;
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (_currentUid != null) {
      _userController.listenToFriendRequests(_currentUid!);
    }
  }

  List<ChatRequest> _parseRequests(List<dynamic> docs) {
    return docs.map((doc) => ChatRequest.fromFirestore(doc as DocumentSnapshot)).toList();
  }

  Future<void> _onAccept(ChatRequest request) async {
    try {
      await _userController.acceptRequest(request.fromUid);
      if (mounted) {
        showSuccessSnackbar('${request.fromName} is now your friend!');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar('Failed to accept: $e');
      }
    }
  }

  Future<void> _onDecline(ChatRequest request) async {
    try {
      await _userController.rejectRequest(request.fromUid);
      if (mounted) {
        showInfoSnackbar('Request from ${request.fromName} declined');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar('Failed to decline: $e');
      }
    }
  }

  Future<void> _onAcceptIgnored(ChatRequest request) async {
    try {
      await _userController.acceptIgnoredRequest(request.fromUid);
      if (mounted) {
        showSuccessSnackbar('${request.fromName} is now your friend!');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar('Failed to accept: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final incoming = _parseRequests(_userController.incomingRequests);
      final ignored = _userController.ignoredRequests.cast<ChatRequest>().toList();

      if (incoming.isEmpty && ignored.isEmpty) {
        return const EmptyRequestsView();
      }

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
                    onAccept: () => _onAccept(request),
                    onDecline: () => _onDecline(request),
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
                    onAccept: () => _onAcceptIgnored(request),
                  )),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}
