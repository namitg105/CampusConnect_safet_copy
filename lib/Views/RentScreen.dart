import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import 'package:noteswap/Widgets/BottonBar/BottomBar.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/NarrowContainer.dart';
import '../Widgets/RentCard/RentNoteCards.dart';


class RentCard extends StatelessWidget {
  RentCard({super.key});
  

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
                itemCount: 2,
                itemBuilder: (context, index) {
                  return RentNotesCard();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      ),
    );
  }
}




