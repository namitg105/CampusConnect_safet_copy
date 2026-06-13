import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import '../ViewModels/DarkModeViewModels.dart';
import 'RentCard/OfferBottom.dart';
import 'RentCard/OfferHeader.dart';

class NoteCard extends StatelessWidget {
  NoteCard({super.key});

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.only(top: 10, right: 22, left: 24, bottom: 18),
          decoration: BoxDecoration(
            color: lightModeController.isLightMode.value ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OfferHeader(
                      color: AppConstants.boxColor,
                    ),
                    const SizedBox(height: 8),
                    OfferBottom(
                      title: Text(
                        "150/-",
                        style: TextStyle(
                          color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/Prievieww.png",
                      width: 110,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "+2",
                        style: TextStyle(
                            color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
