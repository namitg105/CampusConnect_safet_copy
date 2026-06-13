import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import '../../ViewModels/ImageSectionViewModels.dart';
import 'ImageContainer.dart';


class ImageSectionWidgetTwo extends StatelessWidget {
  final ImageSectionController controller;

  ImageSectionWidgetTwo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal scrollable Row of images
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ImageContainer(imagePath: '', index: 0, currentPage: controller.currentPage1),
              ImageContainer(imagePath: '', index: 1, currentPage: controller.currentPage1),
              ImageContainer(imagePath: '', index: 2, currentPage: controller.currentPage1),
            ],
          ),
        ),
        // Hollow dots indicator
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
                  color: controller.currentPage1.value == index ? AppConstants.darkContainerColor : Colors.transparent,
                  border: Border.all(
                    color: controller.currentPage1.value == index ? AppConstants.darkContainerColor : AppConstants.iconNoteColors,
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
