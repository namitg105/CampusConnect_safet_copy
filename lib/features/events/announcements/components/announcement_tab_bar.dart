import 'package:flutter/material.dart';

class AnnouncementTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> labels;
  final List<IconData> icons;

  const AnnouncementTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.labels,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[index],
                        size: 18,
                        color: isSelected
                            ? const Color(0xFF7A5AF8)
                            : const Color(0xFF777777),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF7A5AF8)
                              : const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 110 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A5AF8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
