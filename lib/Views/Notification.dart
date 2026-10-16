import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../Widgets/BottonBar/BottomBar.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/NarrowContainer.dart';
import '../Widgets/RentCard/NotificationCard.dart';
import 'RentScreen.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Scaffold(
        backgroundColor: context.isLightMode ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: context.isLightMode ? Colors.black : Colors.white,
          leading: BackWidget(
            onTap: () {},
            imagePath: context.isLightMode ? AppConstants.backWhiteIcon : AppConstants.backBlackIcon,
          ),
          title: Text(
            AppConstants.noteSwapTexts,
            style: AppStyles.textStyleLargeBold(context),
          ),
          centerTitle: true,
          actions: [
            BackWidget(
              onTap: () {},
              imagePath: context.isLightMode ? AppConstants.whiteSettingIcon : AppConstants.blackSettingIcon,
            ),
          ],
        ),
        body: Column(
          children: [
            NarrowContainer(isLightMode: context.isLightMode,),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                     AppNavigator.push(RentCard());
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
