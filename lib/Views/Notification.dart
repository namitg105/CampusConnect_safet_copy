import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../Widgets/BottonBar/BottomBar.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/NarrowContainer.dart';
import '../Widgets/RentCard/NotificationCard.dart';
import 'RentScreen.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        backgroundColor: lightModeController.isLightMode.value ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: lightModeController.isLightMode.value ? Colors.black : Colors.white,
          leading: BackWidget(
            onTap: () {},
            imagePath: lightModeController.isLightMode.value ? AppConstants.backWhiteIcon : AppConstants.backBlackIcon,
          ),
          title: Text(
            AppConstants.noteSwapTexts,
            style: AppStyles.textStyleLargeBold,
          ),
          centerTitle: true,
          actions: [
            BackWidget(
              onTap: () {},
              imagePath: lightModeController.isLightMode.value ? AppConstants.whiteSettingIcon : AppConstants.blackSettingIcon,
            ),
          ],
        ),
        body: Column(
          children: [
            NarrowContainer(isLightMode: lightModeController.isLightMode.value,),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                     Get.to(RentCard());
                    },
                    child: RentCardCustom(),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
