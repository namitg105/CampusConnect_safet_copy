import 'package:flutter/painting.dart';

import '../../../domain/entities/note_entities.dart';

const List<DashboardNote> myNotesSeed = [
  DashboardNote(
    title: 'Data Structures & Algorithms Notes',
    subject: 'CSE',
    semester: '3rd Semester',
    uploadTime: '2h ago',
    price: 199,
    accent: Color(0xFF6366F1),
    authorId: '',
    buyerIds: ['buyer-1', 'buyer-2', 'buyer-3'],
    ratings: [4.5, 4.5, 4.0],
  ),
  DashboardNote(
    title: 'Operating Systems Notes',
    subject: 'CSE',
    semester: '4th Semester',
    uploadTime: '1d ago',
    price: 179,
    accent: Color(0xFF0EA5E9),
    authorId: '',
    buyerIds: ['buyer-4', 'buyer-5'],
    ratings: [3.0, 4.0],
  ),
  DashboardNote(
    title: 'Microcontrollers & Embedded C',
    subject: 'ECE',
    semester: '5th Semester',
    uploadTime: '3d ago',
    price: 169,
    accent: Color(0xFF06B6D4),
    authorId: '',
    buyerIds: ['buyer-6'],
    ratings: [5.0],
  ),
];

const List<DashboardNote> boughtNotesSeed = [
  DashboardNote(
    title: 'Fluid Mechanics',
    subject: 'Mechanical',
    semester: '5th Semester',
    uploadTime: '2h ago',
    price: 159,
    accent: Color(0xFF6366F1),
    authorId: 'rahul-s',
    buyerIds: ['buyer-1', 'buyer-2'],
    ratings: [4.5, 4.0],
  ),
  DashboardNote(
    title: 'Organic Chemistry',
    subject: 'Chemistry',
    semester: '3rd Semester',
    uploadTime: '5h ago',
    price: 219,
    accent: Color(0xFFF59E0B),
    authorId: 'priya-m',
    buyerIds: ['buyer-3'],
    ratings: [3.0],
  ),
  DashboardNote(
    title: 'Engineering Mathematics II',
    subject: 'Mathematics',
    semester: '2nd Semester',
    uploadTime: '4h ago',
    price: 199,
    accent: Color(0xFFEC4899),
    authorId: 'karan-d',
    buyerIds: ['buyer-4', 'buyer-5', 'buyer-6'],
    ratings: [5.0, 4.5, 4.0],
  ),
];
