import 'package:get/get.dart';
import 'package:noteswap/features/chat/domain/entities/chat_message_entity.dart';
import 'package:noteswap/features/chat/domain/entities/chat_room_entity.dart';
import 'package:noteswap/features/chat/domain/usecases/create_chat_room_usecase.dart';
import 'package:noteswap/features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:noteswap/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:noteswap/features/chat/domain/usecases/send_message_usecase.dart';

class ChatController extends GetxController {
  final CreateChatRoomUseCase createChatRoomUseCase;
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatController({
    required this.createChatRoomUseCase,
    required this.getChatRoomsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  });

  final RxList<ChatRoomEntity> chatRooms = <ChatRoomEntity>[].obs;
  final RxList<ChatMessageEntity> messages = <ChatMessageEntity>[].obs;
  final RxBool isLoadingRooms = true.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString activeRoomId = ''.obs;
  final RxString errorMessage = ''.obs;

  Stream<List<ChatRoomEntity>> roomStream(String collegeId) {
    return getChatRoomsUseCase.call(collegeId);
  }

  Stream<List<ChatMessageEntity>> messageStream(String roomId) {
    return getMessagesUseCase.call(roomId);
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    final message = ChatMessageEntity(
      id: '',
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await sendMessageUseCase.call(roomId, message);
    } catch (e) {
      errorMessage.value = 'Unable to send message: $e';
    }
  }
}
