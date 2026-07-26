import './../models/chat_message_model.dart';

final List<ChatMessage> sampleMessages = [
  ChatMessage(type: ChatMessageType.dateSeparator, dateLabel: 'Today'),
  ChatMessage(
    type: ChatMessageType.text,
    isSender: false,
    text: 'Hey! Did you get a chance to review the wireframes?',
    timestamp: '12:12 PM',
  ),
  ChatMessage(
    type: ChatMessageType.text,
    isSender: true,
    text: 'Yes, I just finished. They look great overall!',
    timestamp: '1:13 PM',
  ),
  ChatMessage(
    type: ChatMessageType.text,
    isSender: false,
    text: 'Awesome! Any feedback on the home screen layout?',
    timestamp: '1:14 PM',
  ),
  ChatMessage(
    type: ChatMessageType.text,
    isSender: true,
    text:
        'The hero section needs more spacing. Also the CTA button should be more prominent.',
    timestamp: '1:15 PM',
  ),
  ChatMessage(
    type: ChatMessageType.image,
    isSender: true,
    timestamp: '1:16 PM',
    imageUrl: 'https://picsum.photos/200/300?grayscale',
  ),
  ChatMessage(type: ChatMessageType.dateSeparator, dateLabel: 'Yesterday'),
  ChatMessage(
    type: ChatMessageType.file,
    isSender: false,
    timestamp: '3:00 PM',
    fileName: 'Wireframe_Spec_v2.pdf',
    fileSize: '2.4 MB',
  ),
  ChatMessage(
    type: ChatMessageType.text,
    isSender: false,
    text: 'Thanks for the detailed feedback!',
    timestamp: '3:02 PM',
  ),
  ChatMessage(
    type: ChatMessageType.text,
    isSender: true,
    text: "No problem! I'll make the changes by EOD.",
    timestamp: '3:05 PM',
  ),
];
