import '../models/announcement_model.dart';

final List<AnnouncementData> hardcodedUniversityAnnouncements = [
  AnnouncementData(
    id: 'uni_1',
    category: AnnouncementCategory.university,
    priority: AnnouncementPriority.critical,
    title: 'Final Examination Timetable — Semester 2, 2026',
    description:
        'The examination schedule for all departments has been released. Students are advised to review the timetable carefully and prepare accordingly. Any conflicts must be reported to the Academic Registry within 48 hours.',
    tags: ['Critical', 'Pinned'],
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    department: 'Academic Registry',
    readTime: '2 min read',
    isRead: false,
    isFeatured: true,
  ),
  AnnouncementData(
    id: 'uni_2',
    category: AnnouncementCategory.university,
    priority: AnnouncementPriority.high,
    title: 'Campus Network Maintenance — May 18, 2–6 AM',
    description:
        'The IT department will perform scheduled infrastructure upgrades on the campus network. During this window, Wi-Fi and wired connections may be intermittent. Cloud-based services will remain available via mobile data.',
    tags: ['High', 'Scheduled'],
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    department: 'IT Services',
    readTime: '1 min read',
    isRead: false,
    isFeatured: false,
  ),
  AnnouncementData(
    id: 'uni_3',
    category: AnnouncementCategory.university,
    priority: AnnouncementPriority.pinned,
    title: 'Scholarship Application Deadline Reminder',
    description:
        'The deadline for submitting merit-based scholarship applications is approaching. Eligible students must submit their documents through the student portal before the cutoff date.',
    tags: ['Pinned'],
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    department: 'Financial Aid Office',
    readTime: '1 min read',
    isRead: true,
    isFeatured: false,
  ),
  AnnouncementData(
    id: 'uni_4',
    category: AnnouncementCategory.university,
    priority: AnnouncementPriority.normal,
    title: 'Library Hours Extended During Finals',
    description:
        'The central library will remain open until 11 PM during the examination period. Additional study rooms have been made available on the third floor.',
    tags: ['Normal'],
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    department: 'Library Services',
    readTime: '1 min read',
    isRead: true,
    isFeatured: false,
  ),
];
