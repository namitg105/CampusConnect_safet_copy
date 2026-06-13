import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'ContainerRow.dart';
import 'RentButton.dart';
import 'RentImages.dart';
import 'RentOfferContainer.dart';

class RentNotesCard extends StatelessWidget {
  RentNotesCard({
    super.key,
  });

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: lightModeController.isLightMode.value ? Colors.black : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerRow(),
                const SizedBox(height: 15),
                RentImage(),
                const SizedBox(height: 15),
                RentOfferContainer(),
                const SizedBox(height: 15),
                RentButton(),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}