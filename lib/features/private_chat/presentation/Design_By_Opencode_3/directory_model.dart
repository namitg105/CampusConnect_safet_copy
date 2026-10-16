import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';

class DirectoryUser {
  final String uid;
  final String name;
  final String initials;
  final String username;
  final String email;
  final String affiliation;
  final Color avatarColor;
  final bool isOnline;
  final bool isFollowing;
  final bool hasRequested;
  final bool hasIncomingRequest;
  final String imageURL;
  final bool isImageExists;

  const DirectoryUser({
    required this.uid,
    required this.name,
    required this.initials,
    required this.username,
    required this.email,
    required this.affiliation,
    required this.avatarColor,
    this.isOnline = false,
    this.isFollowing = false,
    this.hasRequested = false,
    this.hasIncomingRequest = false,
    this.imageURL = '',
    this.isImageExists = false,
  });

  static const _avatarColors = [
    Color(0xFFE8E0FF),
    Color(0xFFD4F5E9),
    Color(0xFFFFE0E6),
    Color(0xFFD4E6FF),
    Color(0xFFFFF3D4),
    Color(0xFFE0F0FF),
    Color(0xFFF0E0FF),
    Color(0xFFD4FFF0),
  ];

  static const _affiliationMap = {
    'vit.ac.in': 'VIT Vellore',
    'vitstudent.ac.in': 'VIT Vellore',
    'vitbhopal.ac.in': 'VIT Bhopal',
    'vitap.ac.in': 'VIT AP',
    'vitchennai.ac.in': 'VIT Chennai',
    'srmstudent.ac.in': 'SRM Vellore',
    'gmail.com': '',
    'yahoo.com': '',
    'outlook.com': '',
  };

  factory DirectoryUser.fromUser(AppUser user,
      {bool isFollowing = false, bool hasRequested = false, bool hasIncomingRequest = false}) {
    final uid = user.uid;
    final name = user.name;
    final email = user.email;

    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts.isNotEmpty
            ? parts[0][0].toUpperCase()
            : '?';

    final emailPrefix = email.split('@')[0];
    final username = emailPrefix.isNotEmpty ? '@$emailPrefix' : '';

    final domain = email.split('@').last.toLowerCase();
    final affiliation = _affiliationMap[domain] ?? '';

    final colorIndex = uid.hashCode.abs() % _avatarColors.length;

    return DirectoryUser(
      uid: uid,
      name: name,
      initials: initials,
      username: username,
      email: email,
      affiliation: affiliation,
      avatarColor: _avatarColors[colorIndex],
      isOnline: user.isOnline,
      isFollowing: isFollowing,
      hasRequested: hasRequested,
      hasIncomingRequest: hasIncomingRequest,
      imageURL: user.imageURL,
      isImageExists: user.isImageExists,
    );
  }

  String get subtitle {
    if (username.isNotEmpty && affiliation.isNotEmpty) {
      return '$username \u00b7 $affiliation';
    }
    return username.isNotEmpty ? username : email;
  }

  String get displayIdentifier => username.isNotEmpty ? username : email;
}
