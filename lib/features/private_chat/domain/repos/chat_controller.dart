import 'dart:async';
import 'package:get/get.dart';
import 'package:noteswap/features/private_chat/domain/entities/pinned_message.dart';
import '../../data/private-chat-services/chat_service.dart';
import '../entities/chat_message.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();

  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxList<Map<String, dynamic>> chatRooms = <Map<String, dynamic>>[].obs;
  Rxn<Map<String, dynamic>> roomInfo = Rxn<Map<String, dynamic>>();
  RxList<Map<String, dynamic>> usersDirectory = <Map<String, dynamic>>[].obs;
  Rxn<PinnedMessage> currentPinnedMessage = Rxn<PinnedMessage>();
  RxString currentRoomId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isDirectoryLoading = false.obs;

  StreamSubscription? _pinnedSubscription;
  StreamSubscription? _directorySubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _roomInfoSubscription;

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _roomsSubscription?.cancel();
    _directorySubscription?.cancel();
    _pinnedSubscription?.cancel();
    _roomInfoSubscription?.cancel();
    super.onClose();
  }

  void listenToDirectory(String currentUid) {
    isDirectoryLoading.value = true;
    _directorySubscription?.cancel();
    _directorySubscription = _chatService.getUsersDirectory(currentUid).listen(
      (
        users,
      ) {
        usersDirectory.value = users;
        isDirectoryLoading.value = false;
      },
      onError: (error) {
        isDirectoryLoading.value = false;
        print("Firestore Error: $error");

        // Optional: Clear the directory or show an empty state
        // so the UI safely renders instead of freezing
        usersDirectory.clear();
      },
    );
  }

  Future<String> createChatRoom(String uid1, String uid2) async {
    isLoading.value = true;
    try {
      String roomId = await _chatService.createChatRoom(uid1, uid2);
      currentRoomId.value = roomId;
      return roomId;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getOrCreateChatRoom(String uid1, String uid2) async {
    return await _chatService.getOrCreateChatRoom(uid1, uid2);
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String message,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? docUrl,
    String? repliedMessageId,
    String? repliedMessageContent,
    String? repliedMessageSender,
    String? repliedMessageType,
    bool skipUnreadIncrement = false,
  }) async {
    if (message.trim().isEmpty && imageUrl == null && docUrl == null) return;
    await _chatService.sendMessage(
      roomId: roomId,
      senderId: senderId,
      receiverId: receiverId,
      message: message.trim(),
      type: type,
      imageUrl: imageUrl,
      docUrl: docUrl,
      repliedMessageId: repliedMessageId,
      repliedMessageContent: repliedMessageContent,
      repliedMessageSender: repliedMessageSender,
      repliedMessageType: repliedMessageType,
      skipUnreadIncrement: skipUnreadIncrement,
    );
  }

  void listenToMessages(String roomId) {
    _messagesSubscription?.cancel();
    currentRoomId.value = roomId;
    _messagesSubscription = _chatService.getMessages(roomId).listen(
      (messageList) {
        messages.value = messageList;
      },
      onError: (error) {
        print("Firestore Error: $error");
        messages.clear();
      },
    );
  }

  void listenToChatRooms(String uid) {
    _roomsSubscription?.cancel();
    _roomsSubscription = _chatService.getUserChatRooms(uid).listen(
      (rooms) {
        chatRooms.value = rooms;
      },
      onError: (error) {
        print("Firestore Error: $error");
        chatRooms.clear();
      },
    );
  }

  void listenToRoomInfo(String roomId, String currentUid) {
    _roomInfoSubscription?.cancel();
    _roomInfoSubscription = _chatService.getRoomInfoStream(roomId, currentUid).listen(
      (info) {
        roomInfo.value = info;
      },
      onError: (error) {
        print("Firestore Error: $error");
        roomInfo.value = null;
      },
    );
  }

  Future<Map<String, dynamic>> getRoomInfo(String roomId, String currentUid) async {
    return await _chatService.getRoomInfo(roomId, currentUid);
  }

  Future<List<String>> fetchAllImagesForRoom(String roomId) async {
    if (roomId.isEmpty) return [];
    return await _chatService.getAllImages(roomId);
  }

  Future<List<Map<String, dynamic>>> fetchAllDocsForRoom(String roomId) async {
    if (roomId.isEmpty) return [];
    return await _chatService.getAllDocs(roomId);
  }

  Future<void> markMessagesAsRead(String roomId, String uid) async {
    await _chatService.markMessagesAsRead(roomId, uid);
  }

  void listenToPinnedMessage(String roomId) {
    _pinnedSubscription?.cancel();
    _pinnedSubscription = _chatService.getPinnedCollection(roomId).listen(
      (pinned) {
        currentPinnedMessage.value = pinned;
      },
      onError: (error) {
        print("Firestore Error: $error");
        currentPinnedMessage.value = null;
      },
    );
  }

  Future<void> pinAMessage(ChatMessage message, String myUid) async {
    if (currentRoomId.isEmpty) return;
    await _chatService.setPinnedMessage(currentRoomId.value, message, myUid);
  }

  Future<void> unpinMessage() async {
    if (currentRoomId.isEmpty) return;
    await _chatService.deletePinnedMessage(currentRoomId.value);
  }

  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _chatService.toggleReaction(
      roomId: roomId,
      messageId: messageId,
      userId: userId,
      emoji: emoji,
    );
  }

  Future<void> removeMessage(ChatMessage msg, String currentUid) async {
    if (currentRoomId.isEmpty) return;
    try {
      await _chatService.deleteMessageAndUpdateType(
        roomId: currentRoomId.value,
        messageId: msg.messageId,
        currentUid: currentUid,
        imageUrlToClean: msg.imageUrl, // Automatically passed if type is image
        docUrlToClean: msg.docUrl,
      );
    } catch (e) {
      print("Error updating deleted message: $e");
    }
  }

  void disposePinnedPipeline() {
    _pinnedSubscription?.cancel();
    currentPinnedMessage.value = null;
  }

  void disposeMessages() {
    _messagesSubscription?.cancel();
    messages.clear();
    currentRoomId.value = '';
  }
}

/*
  Future<void> removeMessage(String messageId, String currentUid) async {
    if (currentRoomId.isEmpty) return;
    try {
      await _chatService.deleteMessage(
        roomId: currentRoomId.value,
        messageId: messageId,
        currentUid: currentUid,
      );
    } catch (e) {
      print("Error deleting message: $e");
    }
  }*/
