import '../models/announcement_model.dart';

final List<AnnouncementData> hardcodedClubAnnouncements = [
  AnnouncementData(
    id: 'club_1',
    category: AnnouncementCategory.club,
    priority: AnnouncementPriority.urgent,
    title: 'Hackathon Registration Closing Tonight',
    description:
        'Only a few spots remain for the 24-hour campus hackathon. Teams of 2–4 members can register through the CS Club portal. Prizes worth ₹50,000 are up for grabs.',
    tags: ['Urgent'],
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    department: 'Computer Science Club',
    readTime: '1 min read',
    isRead: false,
    isFeatured: false,
  ),
  AnnouncementData(
    id: 'club_2',
    category: AnnouncementCategory.club,
    priority: AnnouncementPriority.normal,
    title: 'Photography Club Weekly Meetup',
    description:
        'Join us this Friday at 5 PM in the Media Room for our weekly photography session. This week\'s theme: "Urban Perspectives". Bring your cameras or phones.',
    tags: ['Club'],
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    department: 'Photography Club',
    readTime: '1 min read',
    isRead: true,
    isFeatured: false,
  ),
  AnnouncementData(
    id: 'club_3',
    category: AnnouncementCategory.club,
    priority: AnnouncementPriority.scheduled,
    title: 'Annual Tech Fest Volunteers Needed',
    description:
        'We are looking for enthusiastic volunteers to help organize the annual tech fest. Roles include event coordination, stage management, and technical support. Sign up at the Student Center.',
    tags: ['Scheduled'],
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    department: 'Events Committee',
    readTime: '2 min read',
    isRead: true,
    isFeatured: false,
  ),
];
