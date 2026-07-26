import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String? format;
  final String? category;
  final String? speakerName;
  final String? speakerDescription;
  final String? speakerAvatarUrl;
  final String? bannerUrl;

  Event({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    this.format,
    this.category,
    this.speakerName,
    this.speakerDescription,
    this.speakerAvatarUrl,
    this.bannerUrl,
  });

  factory Event.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Event(
      id: id,
      groupId: map['groupId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      format: map['format'],
      category: map['category'],
      speakerName: map['speakerName'],
      speakerDescription: map['speakerDescription'],
      speakerAvatarUrl: map['speakerAvatarUrl'],
      bannerUrl: map['bannerUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      if (format != null) 'format': format,
      if (category != null) 'category': category,
      if (speakerName != null) 'speakerName': speakerName,
      if (speakerDescription != null) 'speakerDescription': speakerDescription,
      if (speakerAvatarUrl != null) 'speakerAvatarUrl': speakerAvatarUrl,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
    };
  }
}
