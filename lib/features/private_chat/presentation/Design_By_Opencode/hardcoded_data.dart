import 'package:flutter/material.dart';
import 'recent_chats_model.dart';

final List<ConversationData> sampleActiveConversations = [
  ConversationData(
    uid: 'user_1',
    name: 'John Doe',
    initials: 'JD',
    avatarColor: Colors.purple,
    lastMessage: 'Hey, how are you?',
    time: '2:30 PM',
    isOnline: true,
  ),
  ConversationData(
    uid: 'user_2',
    name: 'Jane Smith',
    initials: 'JS',
    avatarColor: Colors.pink,
    lastMessage: 'See you tomorrow!',
    time: '1:15 PM',
    isOnline: true,
  ),
  ConversationData(
    uid: 'user_3',
    name: 'Michael Johnson',
    initials: 'MJ',
    avatarColor: Colors.green,
    lastMessage: 'Thanks for your help',
    time: '12:45 PM',
    isOnline: false,
  ),
  ConversationData(
    uid: 'user_4',
    name: 'Emily Davis',
    initials: 'ED',
    avatarColor: Colors.blue,
    lastMessage: "Let's catch up soon",
    time: '11:30 AM',
    isOnline: true,
  ),
  ConversationData(
    uid: 'user_5',
    name: 'Chris Lee',
    initials: 'CL',
    avatarColor: Colors.amber,
    lastMessage: 'On my way!',
    time: '10:00 AM',
    isOnline: false,
  ),
];

final List<ConversationData> sampleUnreadConversations = [
  ConversationData(
    uid: 'user_6',
    name: 'Sarah Wilson',
    initials: 'SW',
    avatarColor: Colors.blue,
    lastMessage: "Don't forget about the meeting tomorrow",
    time: '3:00 PM',
    isOnline: true,
    unreadCount: 5,
  ),
  ConversationData(
    uid: 'user_7',
    name: 'David Brown',
    initials: 'DB',
    avatarColor: Colors.teal,
    lastMessage: "I've sent you the documents",
    time: '2:45 PM',
    isOnline: false,
    unreadCount: 2,
  ),
];
