import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class OfferBottom extends StatelessWidget {
  final Widget? title;

  OfferBottom({
    super.key,
    this.title,
  });

  final LightModeController lightModeController = Get.put(LightModeController());
  @override
  Widget build(BuildContext context) {
    return Obx(()=> Row(
        children: [
          Expanded(
            child: Text(
              "Computation of \nMathematics",
              style: TextStyle(
                color: lightModeController.isLightMode.value ? Colors.white : Colors.black,
                fontSize: 24,
              ),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 8),
          if (title != null) title! else const SizedBox(),
        ],
      ),
    );
  }
}
