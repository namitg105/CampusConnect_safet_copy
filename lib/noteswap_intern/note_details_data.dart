import 'package:flutter/material.dart';

import 'note_data.dart';

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

const String _img1 = 'https://picsum.photos/id/24/400/320';
const String _img2 = 'https://picsum.photos/id/20/400/320';
const String _img3 = 'https://picsum.photos/id/42/400/320';
const String _img4 = 'https://picsum.photos/id/26/400/320';
const String _img5 = 'https://picsum.photos/id/44/400/320';
const String _img6 = 'https://picsum.photos/id/1/400/320';
const String _img7 = 'https://picsum.photos/id/1011/400/320';
const String _img8 = 'https://picsum.photos/id/1068/400/320';
const String _img9 = 'https://picsum.photos/id/237/400/320';
const String _img10 = 'https://picsum.photos/id/1084/400/320';
const String _img11 = 'https://picsum.photos/id/1080/400/320';
const String _img12 = 'https://picsum.photos/id/1062/400/320';

const Map<String, NoteDetail> noteDetails = {
  'Data Structures & Algorithms': NoteDetail(
    title: 'Data Structures & Algorithms',
    subject: 'CSE',
    author: 'Ankit K.',
    price: '₹199',
    rating: 4.8,
    ratingCount: 214,
    images: [_img1, _img7, _img8],
    semester: '3rd Semester',
    pages: '412 pages',
    language: 'English',
    fileSize: '14 MB',
    downloads: 486,
    sellerName: 'Ankit K.',
    sellerJoined: 'Joined Mar 2025',
    sellerNotes: 27,
    sellerAccent: Color(0xFF6366F1),
    reviews: [
      Review(
        name: 'Ritika J.',
        rating: 5.0,
        time: '2d ago',
        text: 'Perfect for exams. Clear explanation of every topic with solved examples.',
      ),
      Review(
        name: 'Aditya N.',
        rating: 4.5,
        time: '1w ago',
        text: 'Well organised notes. The diagrams and flowcharts helped me a lot.',
      ),
      Review(
        name: 'Megha S.',
        rating: 4.0,
        time: '2w ago',
        text: 'Good quality PDF, a few topics could have been covered in more depth.',
      ),
    ],
  ),
  'Database Management Systems': NoteDetail(
    title: 'Database Management Systems',
    subject: 'CSE',
    author: 'Ankit K.',
    price: '₹149',
    rating: 4.6,
    ratingCount: 96,
    images: [_img2, _img7, _img8],
    semester: '4th Semester',
    pages: '328 pages',
    language: 'English',
    fileSize: '9 MB',
    downloads: 120,
    sellerName: 'Ankit K.',
    sellerJoined: 'Joined Mar 2025',
    sellerNotes: 27,
    sellerAccent: Color(0xFF10B981),
    reviews: [
      Review(
        name: 'Karan D.',
        rating: 5.0,
        time: '3d ago',
        text: 'SQL queries section is very practical. Helped me score well in viva.',
      ),
      Review(
        name: 'Shreya P.',
        rating: 4.5,
        time: '1w ago',
        text: 'Easy to follow, good ER diagram examples.',
      ),
    ],
  ),
  'Operating Systems Notes': NoteDetail(
    title: 'Operating Systems Notes',
    subject: 'CSE',
    author: 'Ritika J.',
    price: '₹179',
    rating: 4.7,
    ratingCount: 142,
    images: [_img3, _img9, _img10],
    semester: '4th Semester',
    pages: '356 pages',
    language: 'English',
    fileSize: '11 MB',
    downloads: 301,
    sellerName: 'Ritika J.',
    sellerJoined: 'Joined Jan 2025',
    sellerNotes: 18,
    sellerAccent: Color(0xFF0EA5E9),
    reviews: [
      Review(
        name: 'Varun P.',
        rating: 5.0,
        time: '4d ago',
        text: 'Process scheduling chapter is explained better than my textbook.',
      ),
      Review(
        name: 'Nikhil B.',
        rating: 4.0,
        time: '2w ago',
        text: 'Comprehensive notes with good memory tricks.',
      ),
    ],
  ),
  'Fluid Mechanics': NoteDetail(
    title: 'Fluid Mechanics',
    subject: 'Mechanical',
    author: 'Rahul S.',
    price: '₹159',
    rating: 4.5,
    ratingCount: 178,
    images: [_img4, _img11, _img12],
    semester: '5th Semester',
    pages: '298 pages',
    language: 'English',
    fileSize: '12 MB',
    downloads: 342,
    sellerName: 'Rahul S.',
    sellerJoined: 'Joined Aug 2024',
    sellerNotes: 31,
    sellerAccent: Color(0xFF6366F1),
    reviews: [
      Review(
        name: 'Imran A.',
        rating: 5.0,
        time: '5d ago',
        text: 'Numerical problems are solved step by step. Very helpful.',
      ),
      Review(
        name: 'Sneha R.',
        rating: 4.0,
        time: '3w ago',
        text: 'Bernoulli section could use more diagrams.',
      ),
    ],
  ),
  'Thermodynamics Basics': NoteDetail(
    title: 'Thermodynamics Basics',
    subject: 'Mechanical',
    author: 'Imran A.',
    price: '₹129',
    rating: 4.4,
    ratingCount: 87,
    images: [_img5, _img11, _img12],
    semester: '4th Semester',
    pages: '254 pages',
    language: 'English',
    fileSize: '8 MB',
    downloads: 189,
    sellerName: 'Imran A.',
    sellerJoined: 'Joined Sep 2024',
    sellerNotes: 12,
    sellerAccent: Color(0xFFF97316),
    reviews: [
      Review(
        name: 'Rahul S.',
        rating: 4.5,
        time: '1w ago',
        text: 'First and second law derivations are clean and concise.',
      ),
      Review(
        name: 'Divya S.',
        rating: 4.0,
        time: '2w ago',
        text: 'Helped me prepare quickly for the midterm exam.',
      ),
    ],
  ),
  'Organic Chemistry': NoteDetail(
    title: 'Organic Chemistry',
    subject: 'Chemistry',
    author: 'Priya M.',
    price: '₹219',
    rating: 4.9,
    ratingCount: 203,
    images: [_img6, _img7, _img8],
    semester: '3rd Semester',
    pages: '380 pages',
    language: 'English',
    fileSize: '16 MB',
    downloads: 278,
    sellerName: 'Priya M.',
    sellerJoined: 'Joined Feb 2025',
    sellerNotes: 22,
    sellerAccent: Color(0xFFF59E0B),
    reviews: [
      Review(
        name: 'Neha V.',
        rating: 5.0,
        time: '2d ago',
        text: 'Reaction mechanisms with arrow pushing are beautifully explained.',
      ),
      Review(
        name: 'Aditya N.',
        rating: 5.0,
        time: '6d ago',
        text: 'Named reactions chapter is a lifesaver for revision.',
      ),
      Review(
        name: 'Megha S.',
        rating: 4.5,
        time: '2w ago',
        text: 'Great handwriting and colour coding throughout.',
      ),
    ],
  ),
  'Inorganic Chemistry Notes': NoteDetail(
    title: 'Inorganic Chemistry Notes',
    subject: 'Chemistry',
    author: 'Neha V.',
    price: '₹139',
    rating: 4.3,
    ratingCount: 64,
    images: [_img7, _img6, _img8],
    semester: '3rd Semester',
    pages: '210 pages',
    language: 'English',
    fileSize: '7 MB',
    downloads: 154,
    sellerName: 'Neha V.',
    sellerJoined: 'Joined Apr 2025',
    sellerNotes: 9,
    sellerAccent: Color(0xFF84CC16),
    reviews: [
      Review(
        name: 'Priya M.',
        rating: 4.5,
        time: '5d ago',
        text: 'Coordination compounds section is really well summarised.',
      ),
      Review(
        name: 'Ankit K.',
        rating: 4.0,
        time: '1w ago',
        text: 'Great revision notes, d-block trends are very clear.',
      ),
    ],
  ),
  'Digital Signal Processing': NoteDetail(
    title: 'Digital Signal Processing',
    subject: 'ECE',
    author: 'Varun P.',
    price: '₹189',
    rating: 4.6,
    ratingCount: 121,
    images: [_img8, _img9, _img10],
    semester: '5th Semester',
    pages: '342 pages',
    language: 'English',
    fileSize: '13 MB',
    downloads: 210,
    sellerName: 'Varun P.',
    sellerJoined: 'Joined Oct 2024',
    sellerNotes: 15,
    sellerAccent: Color(0xFF8B5CF6),
    reviews: [
      Review(
        name: 'Sahil T.',
        rating: 5.0,
        time: '3d ago',
        text: 'FFT and z-transform topics made very easy to grasp.',
      ),
      Review(
        name: 'Karan D.',
        rating: 4.0,
        time: '2w ago',
        text: 'Good set of solved GATE-style problems.',
      ),
    ],
  ),
  'Microcontrollers & Embedded C': NoteDetail(
    title: 'Microcontrollers & Embedded C',
    subject: 'ECE',
    author: 'Sahil T.',
    price: '₹169',
    rating: 4.5,
    ratingCount: 73,
    images: [_img9, _img1, _img2],
    semester: '5th Semester',
    pages: '266 pages',
    language: 'English',
    fileSize: '10 MB',
    downloads: 167,
    sellerName: 'Sahil T.',
    sellerJoined: 'Joined Dec 2024',
    sellerNotes: 11,
    sellerAccent: Color(0xFF06B6D4),
    reviews: [
      Review(
        name: 'Varun P.',
        rating: 4.5,
        time: '1w ago',
        text: 'Register maps and example programs are very handy.',
      ),
      Review(
        name: 'Ritika J.',
        rating: 4.5,
        time: '2w ago',
        text: 'Timers and interrupts chapter is explained perfectly.',
      ),
    ],
  ),
  'Microeconomics Notes': NoteDetail(
    title: 'Microeconomics Notes',
    subject: 'Economics',
    author: 'Sneha R.',
    price: '₹119',
    rating: 4.2,
    ratingCount: 58,
    images: [_img10, _img11, _img12],
    semester: '2nd Semester',
    pages: '188 pages',
    language: 'English',
    fileSize: '6 MB',
    downloads: 95,
    sellerName: 'Sneha R.',
    sellerJoined: 'Joined May 2025',
    sellerNotes: 8,
    sellerAccent: Color(0xFFEF4444),
    reviews: [
      Review(
        name: 'Divya S.',
        rating: 4.5,
        time: '4d ago',
        text: 'Supply-demand graphs are very clear.',
      ),
      Review(
        name: 'Ritika J.',
        rating: 4.0,
        time: '3w ago',
        text: 'Concise and to the point for quick revision.',
      ),
    ],
  ),
  'Engineering Mathematics II': NoteDetail(
    title: 'Engineering Mathematics II',
    subject: 'Mathematics',
    author: 'Karan D.',
    price: '₹199',
    rating: 4.7,
    ratingCount: 156,
    images: [_img11, _img3, _img4],
    semester: '2nd Semester',
    pages: '364 pages',
    language: 'English',
    fileSize: '15 MB',
    downloads: 233,
    sellerName: 'Karan D.',
    sellerJoined: 'Joined Jul 2024',
    sellerNotes: 20,
    sellerAccent: Color(0xFFEC4899),
    reviews: [
      Review(
        name: 'Ankit K.',
        rating: 5.0,
        time: '2d ago',
        text: 'Line integrals and Laplace transforms are covered really well.',
      ),
      Review(
        name: 'Sneha R.',
        rating: 4.5,
        time: '1w ago',
        text: 'Every theorem is followed by a worked example.',
      ),
    ],
  ),
  'Physics: Electromagnetism': NoteDetail(
    title: 'Physics: Electromagnetism',
    subject: 'Physics',
    author: 'Divya S.',
    price: '₹149',
    rating: 4.4,
    ratingCount: 89,
    images: [_img12, _img5, _img6],
    semester: '1st Semester',
    pages: '240 pages',
    language: 'English',
    fileSize: '9 MB',
    downloads: 128,
    sellerName: 'Divya S.',
    sellerJoined: 'Joined Jun 2024',
    sellerNotes: 13,
    sellerAccent: Color(0xFF3B82F6),
    reviews: [
      Review(
        name: 'Imran A.',
        rating: 4.5,
        time: '6d ago',
        text: 'Maxwell equations chapter is exceptionally good.',
      ),
      Review(
        name: 'Sahil T.',
        rating: 5.0,
        time: '2w ago',
        text: 'Every derivation is neatly presented with diagrams.',
      ),
    ],
  ),
};

NoteDetail noteDetailFor(Note note) {
  return noteDetails[note.title] ?? noteDetails.values.first;
}
