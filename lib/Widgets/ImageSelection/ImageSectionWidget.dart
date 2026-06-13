import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import '../../ViewModels/ImageSectionViewModels.dart';
import 'ImageContainer.dart';


class ImageSectionWidget extends StatelessWidget {
  final ImageSectionController controller;

  ImageSectionWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal scrollable Row of images
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ImageContainer(imagePath: 'assets/Designer27.png', index: 0, currentPage: controller.currentPage),
              ImageContainer(imagePath: 'assets/Designer28.png', index: 1, currentPage: controller.currentPage),
              ImageContainer(imagePath: '', index: 2, currentPage: controller.currentPage),
            ],
          ),
        ),
        SizedBox(height: 10),
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
                  (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.currentPage.value == index ? AppConstants.darkContainerColor : Colors.transparent,
                  border: Border.all(
                    color: controller.currentPage.value == index ? AppConstants.darkContainerColor : AppConstants.iconNoteColors,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
