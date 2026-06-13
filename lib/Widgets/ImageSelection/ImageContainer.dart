import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class ImageContainer extends StatelessWidget {
  final String imagePath;
  final int index;
  final RxInt currentPage;

  ImageContainer({
    required this.imagePath,
    required this.index,
    required this.currentPage,
  });

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        currentPage.value = index;
      },
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
                  color: lightModeController.isLightMode.value ? AppConstants.darkContainerColor : AppConstants.lightContainerColor,
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
