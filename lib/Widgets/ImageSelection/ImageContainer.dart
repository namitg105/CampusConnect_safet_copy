import 'package:flutter/material.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import 'package:noteswap/core/theme/theme_context.dart';

class ImageContainer extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const ImageContainer({
    super.key,
    required this.imagePath,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            fit: BoxFit.fitWidth,
            width: 120,
            height: 160,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: context.isLightMode ? AppConstants.darkContainerColor : AppConstants.lightContainerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
