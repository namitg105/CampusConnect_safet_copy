import '../models/announcement_model.dart';

final List<AnnouncementData> hardcodedEventAnnouncements = [
  AnnouncementData(
    id: 'evt_1',
    category: AnnouncementCategory.events,
    priority: AnnouncementPriority.urgent,
    title: 'Tech Fest 2026 — Keynote Speakers Announced',
    description:
        'We are thrilled to announce the keynote speakers for Tech Fest 2026. Industry leaders from Google, Microsoft, and leading startups will be sharing their insights over three action-packed days.',
    tags: ['Featured', 'Events'],
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    department: 'Events Committee',
    readTime: '2 min read',
    isRead: false,
    isFeatured: true,
  ),
  AnnouncementData(
    id: 'evt_2',
    category: AnnouncementCategory.events,
    priority: AnnouncementPriority.high,
    title: 'Annual Sports Day Schedule Released',
    description:
        'The schedule for the annual sports day has been finalized. Events include cricket, football, athletics, and badminton. Registrations are open through the Sports Council portal.',
    tags: ['High'],
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    department: 'Sports Council',
    readTime: '1 min read',
    isRead: false,
    isFeatured: false,
  ),
  AnnouncementData(
    id: 'evt_3',
    category: AnnouncementCategory.events,
    priority: AnnouncementPriority.normal,
    title: 'Cultural Night Auditions Open',
    description:
        'Auditions for the annual cultural night are now open. Solo and group performances in music, dance, and drama are welcome. Auditions will be held in the Auditorium this weekend.',
    tags: ['Events'],
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    department: 'Cultural Committee',
    readTime: '1 min read',
    isRead: true,
    isFeatured: false,
  ),
];
