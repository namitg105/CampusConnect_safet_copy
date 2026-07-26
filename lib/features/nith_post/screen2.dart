import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Discover your campus',
                style: TextStyle(
                    color: Colors.grey, fontSize: 13, letterSpacing: 1),
              ),
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const SearchBarWidget(),
              const SizedBox(height: 24),
              const TrendingTopicsWidget(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'SUGGESTED POSTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PostCardWidget(
                avatarUrl:
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                authorName: 'Priya Sharma',
                subtitle: 'SCOPE • 18 hrs ago',
                title:
                    'Best resources to clear STS and Java Fats absolute beginners',
                bodyText:
                    'After two semesters trying to maintain a 9+ CGPA in B.Tech CSE, I finally have a study roadmap for the upcoming FATs that actually works, starting with...',
                imageUrl:
                    'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600',
                tags: const ['#VITVellore', '#SCOPE', '#FATs'],
                likes: 44,
                comments: 17,
              ),
              const SizedBox(height: 16),
              const PostCardWidget(
                avatarUrl:
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                authorName: 'Jerome Obelor',
                subtitle: 'VITSOL • 19 hrs ago',
                title: 'CAT 2 Study group forming – all branches welcome',
                bodyText:
                    'Kicking off a cross-school study group to share digital notes and resources. We\'ll meet at the Netaji Auditorium or Central Library every Tuesday and...',
                tags: ['#VITVellore', '#CAT2', '#StudyGroups'],
                likes: 48,
                comments: 28,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'search posts, people, topics...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }
}

class TrendingTopicsWidget extends StatelessWidget {
  const TrendingTopicsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Localized topics for VIT Vellore with appropriate styling matching your schema
    final List<Map<String, dynamic>> topics = [
      {
        'label': '🔥 FATs Study Tips',
        'bg': const Color(0xFF7C4DFF),
        'text': Colors.white
      },
      {
        'label': '🎨 Riviera 2026',
        'bg': const Color(0xFF1E88E5),
        'text': Colors.white
      },
      {
        'label': '🍕 Night Canteen Reviews',
        'bg': const Color(0xFFFFF3E0),
        'text': const Color(0xFFE65100)
      },
      {
        'label': 'Research under SCOPE',
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF2E7D32)
      },
      {
        'label': 'Gravitas Hackathons',
        'bg': const Color(0xFFEDE7F6),
        'text': const Color(0xFF7C4DFF)
      },
      {
        'label': 'FFCS Timetable Help',
        'bg': const Color(0xFFE8EAF6),
        'text': Colors.indigo.shade400
      },
      {
        'label': 'Hostel Room Allotment',
        'bg': const Color(0xFFF3E5F5),
        'text': Colors.purple.shade400
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF7C4DFF)),
                SizedBox(width: 8),
                Text(
                  'Trending Topics',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text('All', style: TextStyle(color: Color(0xFF7C4DFF))),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF7C4DFF)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: topics.map((topic) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: topic['bg'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: RichText(
                text: TextSpan(
                  text: '${topic['label']} ',
                  style: TextStyle(
                      color: topic['text'],
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  children: [
                    TextSpan(
                      text: topic['count'],
                      style: TextStyle(
                          color: (topic['text'] as Color).withOpacity(0.6),
                          fontWeight: FontWeight.normal,
                          fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PostCardWidget extends StatelessWidget {
  final String avatarUrl;
  final String authorName;
  final String subtitle;
  final String title;
  final String bodyText;
  final String? imageUrl;
  final List<String> tags;
  final int likes;
  final int comments;

  const PostCardWidget({
    super.key,
    required this.avatarUrl,
    required this.authorName,
    required this.subtitle,
    required this.title,
    required this.bodyText,
    this.imageUrl,
    required this.tags,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl), radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.keyboard_control, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            bodyText,
            style: const TextStyle(
                color: Colors.black54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            children: tags
                .map((tag) => Text(tag,
                    style: const TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)))
                .toList(),
          ),
          const Divider(height: 24, thickness: 0.5, color: Color(0xFFEEEEEE)),
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 4),
              Text('$likes',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline,
                  color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text('$comments',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
              const Spacer(),
              const Icon(Icons.bookmark_border,
                  color: Color(0xFF7C4DFF), size: 20),
            ],
          )
        ],
      ),
    );
  }
}
