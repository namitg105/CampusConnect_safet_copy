import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../domain/entities/group.dart';
import '../presentation/cubits/group_cubit.dart';
import '../../chat/presentation/cubits/chat_cubit.dart';
import '../../chat/presentation/pages/chatPage.dart';

class CommunitiesPage extends StatefulWidget {
  final List<Group> groups;

  const CommunitiesPage({
    super.key,
    required this.groups,
  });

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String search = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = widget.groups.where((group) {
      final query = search.toLowerCase();
      return group.name.toLowerCase().contains(query) ||
          group.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF4F2FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 170,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 30, 18, 10),
              decoration: const BoxDecoration(
                color: Color(0xff6139ED),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "My Communities",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Positioned(
                            child: Image.asset(
                              "assets/community/notification.png",
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Row(
                    children: [
                      Expanded(child: FilterButton(title: "Joined")),
                      SizedBox(width: 12),
                      Expanded(child: FilterButton(title: "Favourites")),
                      SizedBox(width: 12),
                      Expanded(child: FilterButton(title: "Activity")),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search for communities...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Pinned",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4B4B87),
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(height: 25),
                    const Text(
                      "All Communities",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4B4B87),
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (filteredGroups.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            "No joined communities found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredGroups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final group = filteredGroups[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) => sl<ChatCubit>(),
                                    child: ChatPage(
                                      groupId: group.id,
                                      groupName: group.name,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: CommunityCard(
                              title: group.name,
                              memberCount:
                                  group.memberCount, // Updated payload mapping
                              category: group.description,
                              imageUrl: group.imageUrl,
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 25),
                    const Center(
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xff6C3DF4),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            backgroundColor: const Color(0xffEFE9FF),
                            foregroundColor: const Color(0xff6C3DF4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: Color(0xff6C3DF4),
                              ),
                            ),
                          ),
                          onPressed: () {
                            context.read<GroupCubit>().loadGroups();
                          },
                          child: const Text(
                            "Discover more",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String title;

  const FilterButton({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CommunityCard extends StatelessWidget {
  final String title;
  final int memberCount; // Fixed: Changed type from String to int
  final String category;
  final String imageUrl;

  const CommunityCard({
    super.key,
    required this.title,
    required this.memberCount,
    required this.category,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: (imageUrl.trim().isEmpty)
                ? Image.asset(
                    "assets/community/blue_profile.png",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imageUrl.trim(),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Image.asset(
                        "assets/community/blue_profile.png",
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/community/blue_profile.png",
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$memberCount Members • $category", // Fixed format interpolation
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
