import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String? category;
  final String? format;
  final String? speakerName;
  final String? speakerDescription;
  final String? speakerAvatarUrl;
  final String? bannerUrl;
  final String groupId;
  final String createdBy;
  final String status;
  final int filledSpots;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    this.category,
    this.format,
    this.speakerName,
    this.speakerDescription,
    this.speakerAvatarUrl,
    this.bannerUrl,
    required this.groupId,
    required this.createdBy,
    required this.status,
    required this.filledSpots,
  });

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: map['category'],
      format: map['format'],
      speakerName: map['speakerName'],
      speakerDescription: map['speakerDescription'],
      speakerAvatarUrl: map['speakerAvatarUrl'],
      bannerUrl: map['bannerUrl'],
      groupId: map['groupId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'active',
      filledSpots: map['filledSpots'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'category': category,
      'format': format,
      'speakerName': speakerName,
      'speakerDescription': speakerDescription,
      'speakerAvatarUrl': speakerAvatarUrl,
      'bannerUrl': bannerUrl,
      'groupId': groupId,
      'createdBy': createdBy,
      'status': status,
      'filledSpots': filledSpots,
    };
  }
}
