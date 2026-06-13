import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/Widgets/BottonBar/BottomBar.dart';
import 'package:noteswap/Widgets/NarrowContainer.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/Feed/SearchCard.dart';
import '../Widgets/Feed/SearchSort.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});
  
  final LightModeController lightModeController = Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    List<Color> searchCardColors = [
      AppConstants.boxColor,
      AppConstants.blueColors,
      AppConstants.redColors,
      AppConstants.yellowColors,
      AppConstants.darkYellowColors,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
      AppConstants.boxColor,
    ];

    return Obx(
      ()=> Scaffold(
        backgroundColor: lightModeController.isLightMode.value ? Colors.white: Colors.black,
        appBar: AppBar(
          backgroundColor: lightModeController.isLightMode.value ? Colors.black: Colors.white,
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
            SearchSort(),
            Expanded(
              child: ListView.builder(
                itemCount: searchCardColors.length,
                itemBuilder: (context, index) {
                  return SearchCard(color: searchCardColors[index]);
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
