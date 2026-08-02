import 'package:flutter/material.dart';

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

const List<Note> featuredNotes = [
  Note(
    title: 'Fluid Mechanics',
    subject: 'Mechanical',
    author: 'Rahul S.',
    uploadTime: '2h ago',
    downloads: 342,
    accent: Color(0xFF6366F1),
  ),
  Note(
    title: 'Organic Chemistry',
    subject: 'Chemistry',
    author: 'Priya M.',
    uploadTime: '5h ago',
    downloads: 278,
    accent: Color(0xFFF59E0B),
  ),
];

const List<Note> recentNotes = [
  Note(
    title: 'Database Management Systems',
    subject: 'CSE',
    author: 'Ankit K.',
    uploadTime: '10 min ago',
    downloads: 120,
    accent: Color(0xFF10B981),
  ),
  Note(
    title: 'Microeconomics Notes',
    subject: 'Economics',
    author: 'Sneha R.',
    uploadTime: '1h ago',
    downloads: 95,
    accent: Color(0xFFEF4444),
  ),
  Note(
    title: 'Digital Signal Processing',
    subject: 'ECE',
    author: 'Varun P.',
    uploadTime: '3h ago',
    downloads: 210,
    accent: Color(0xFF8B5CF6),
  ),
];

const List<Note> searchNotes = [
  Note(
    title: 'Data Structures & Algorithms',
    subject: 'CSE',
    author: 'Ankit K.',
    uploadTime: '2h ago',
    downloads: 486,
    accent: Color(0xFF6366F1),
  ),
  Note(
    title: 'Database Management Systems',
    subject: 'CSE',
    author: 'Ankit K.',
    uploadTime: '10 min ago',
    downloads: 120,
    accent: Color(0xFF10B981),
  ),
  Note(
    title: 'Operating Systems Notes',
    subject: 'CSE',
    author: 'Ritika J.',
    uploadTime: '6h ago',
    downloads: 301,
    accent: Color(0xFF0EA5E9),
  ),
  Note(
    title: 'Fluid Mechanics',
    subject: 'Mechanical',
    author: 'Rahul S.',
    uploadTime: '2h ago',
    downloads: 342,
    accent: Color(0xFF6366F1),
  ),
  Note(
    title: 'Thermodynamics Basics',
    subject: 'Mechanical',
    author: 'Imran A.',
    uploadTime: '1d ago',
    downloads: 189,
    accent: Color(0xFFF97316),
  ),
  Note(
    title: 'Organic Chemistry',
    subject: 'Chemistry',
    author: 'Priya M.',
    uploadTime: '5h ago',
    downloads: 278,
    accent: Color(0xFFF59E0B),
  ),
  Note(
    title: 'Inorganic Chemistry Notes',
    subject: 'Chemistry',
    author: 'Neha V.',
    uploadTime: '2d ago',
    downloads: 154,
    accent: Color(0xFF84CC16),
  ),
  Note(
    title: 'Digital Signal Processing',
    subject: 'ECE',
    author: 'Varun P.',
    uploadTime: '3h ago',
    downloads: 210,
    accent: Color(0xFF8B5CF6),
  ),
  Note(
    title: 'Microcontrollers & Embedded C',
    subject: 'ECE',
    author: 'Sahil T.',
    uploadTime: '8h ago',
    downloads: 167,
    accent: Color(0xFF06B6D4),
  ),
  Note(
    title: 'Microeconomics Notes',
    subject: 'Economics',
    author: 'Sneha R.',
    uploadTime: '1h ago',
    downloads: 95,
    accent: Color(0xFFEF4444),
  ),
  Note(
    title: 'Engineering Mathematics II',
    subject: 'Mathematics',
    author: 'Karan D.',
    uploadTime: '4h ago',
    downloads: 233,
    accent: Color(0xFFEC4899),
  ),
  Note(
    title: 'Physics: Electromagnetism',
    subject: 'Physics',
    author: 'Divya S.',
    uploadTime: '1d ago',
    downloads: 128,
    accent: Color(0xFF3B82F6),
  ),
];
