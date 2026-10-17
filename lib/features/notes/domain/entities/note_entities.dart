import 'package:flutter/painting.dart';

/// Note entities shown across the Notes screens.
///
/// They carry an accent [Color] (derived from the subject) that the cards
/// use directly; that is the only Flutter type in this layer.

class Note {
  final String id;
  final String title;
  final String subject;
  final String author;
  final String uploadTime;
  final int downloads;
  final Color accent;

  const Note({
    this.id = '',
    required this.title,
    required this.subject,
    required this.author,
    required this.uploadTime,
    required this.downloads,
    required this.accent,
  });
}

class DashboardNote {
  final String id;
  final String title;
  final String subject;
  final String semester;
  final String uploadTime;
  final int price;
  final Color accent;
  final String authorId;
  final List<String> buyerIds;
  final List<double> ratings;

  const DashboardNote({
    this.id = '',
    required this.title,
    required this.subject,
    required this.semester,
    required this.uploadTime,
    required this.price,
    required this.accent,
    required this.authorId,
    required this.buyerIds,
    required this.ratings,
  });

  DashboardNote copyWith({
    String? id,
    String? authorId,
    List<String>? buyerIds,
  }) {
    return DashboardNote(
      id: id ?? this.id,
      title: title,
      subject: subject,
      semester: semester,
      uploadTime: uploadTime,
      price: price,
      accent: accent,
      authorId: authorId ?? this.authorId,
      buyerIds: buyerIds ?? this.buyerIds,
      ratings: ratings,
    );
  }
}

class Review {
  final String name;
  final double rating;
  final String time;
  final String text;

  const Review({
    required this.name,
    required this.rating,
    required this.time,
    required this.text,
  });
}

class NoteDetail {
  final String noteId;
  final String title;
  final String subject;
  final String author;
  final String price;
  final double rating;
  final int ratingCount;
  final List<String> images;
  final String semester;
  final String pages;
  final String language;
  final String fileSize;
  final int downloads;
  final String sellerName;
  final String sellerJoined;
  final int sellerNotes;
  final Color sellerAccent;
  final List<Review> reviews;
  final String fileUrl;
  final bool isOwner;
  final bool isPurchased;

  const NoteDetail({
    this.noteId = '',
    required this.title,
    required this.subject,
    required this.author,
    required this.price,
    required this.rating,
    required this.ratingCount,
    required this.images,
    required this.semester,
    required this.pages,
    required this.language,
    required this.fileSize,
    required this.downloads,
    required this.sellerName,
    required this.sellerJoined,
    required this.sellerNotes,
    required this.sellerAccent,
    required this.reviews,
    this.fileUrl = '',
    this.isOwner = false,
    this.isPurchased = false,
  });

  NoteDetail copyWith({
    String? fileUrl,
    bool? isOwner,
    bool? isPurchased,
    int? downloads,
  }) {
    return NoteDetail(
      noteId: noteId,
      title: title,
      subject: subject,
      author: author,
      price: price,
      rating: rating,
      ratingCount: ratingCount,
      images: images,
      semester: semester,
      pages: pages,
      language: language,
      fileSize: fileSize,
      downloads: downloads ?? this.downloads,
      sellerName: sellerName,
      sellerJoined: sellerJoined,
      sellerNotes: sellerNotes,
      sellerAccent: sellerAccent,
      reviews: reviews,
      fileUrl: fileUrl ?? this.fileUrl,
      isOwner: isOwner ?? this.isOwner,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}
