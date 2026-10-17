import 'package:flutter/material.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import 'ImageContainer.dart';

/// A horizontal row of image cards with a dot indicator. The selected dot
/// is purely local UI state, so it lives in this widget.
///
/// Replaces ImageSectionWidget / WidgetTwo / WidgetThree, which differed
/// only in their image paths.
class ImageSectionWidget extends StatefulWidget {
  /// Empty paths show a coloured placeholder card.
  final List<String> imagePaths;

  const ImageSectionWidget({super.key, required this.imagePaths});

  @override
  State<ImageSectionWidget> createState() => _ImageSectionWidgetState();
}

class _ImageSectionWidgetState extends State<ImageSectionWidget> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal scrollable Row of images
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < widget.imagePaths.length; i++)
                ImageContainer(
                  imagePath: widget.imagePaths[i],
                  onTap: () => setState(() => _currentPage = i),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Hollow dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imagePaths.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? AppConstants.darkContainerColor
                    : Colors.transparent,
                border: Border.all(
                  color: _currentPage == index
                      ? AppConstants.darkContainerColor
                      : AppConstants.iconNoteColors,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
