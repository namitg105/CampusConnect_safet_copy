import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class DividerWidgets extends StatelessWidget {
  DividerWidgets({
    super.key,
  });

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: lightModeController.isLightMode.value ? Colors.white70: Colors.black,)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Or",
              style: TextStyle(color: lightModeController.isLightMode.value ? Colors.white70: Colors.black)),
        ),
        Expanded(child: Divider(color: lightModeController.isLightMode.value ? Colors.white70: Colors.black)),
      ],
    );
  }
}