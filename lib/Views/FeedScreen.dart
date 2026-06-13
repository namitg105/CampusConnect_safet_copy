import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../ViewModels/ImageSectionViewModels.dart';
import '../Widgets/BottonBar/BottomBar.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/Buttons/ButtonWidgets.dart';
import '../Widgets/Feed/SearchWidgets.dart';
import '../Widgets/ImageSelection/ImageSectionWidget.dart';
import '../Widgets/ImageSelection/ImageSectionWidgetThree.dart';
import '../Widgets/ImageSelection/ImageSectionWidgetTwo.dart';
import '../Widgets/LibraryOptionWidget.dart';
import '../Widgets/NarrowContainer.dart';

class FeedScreen extends StatelessWidget {
  final ImageSectionController imageController = Get.put(ImageSectionController());
  final LightModeController lightModeController = Get.put(LightModeController());

  FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        backgroundColor: lightModeController.isLightMode.value? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: lightModeController.isLightMode.value? Colors.black : Colors.white,
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Container
              NarrowContainer(isLightMode: lightModeController.isLightMode.value,),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56.0),
                child: SearchWidgets(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: "Explore our Library"
                    Text(
                      "Explore our Library",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lightModeController.isLightMode.value? Colors.black : Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LibraryOptionWidget(
                          iconPath: AppConstants.container1Icon,
                          label: "Available Notes",
                        ),
                        LibraryOptionWidget(
                          iconPath: AppConstants.container2Icon,
                          label: "Newly added",
                        ),
                        LibraryOptionWidget(
                          iconPath: AppConstants.container3Icon,
                          label: "Top selling",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Explore the Departments",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lightModeController.isLightMode.value? Colors.black : Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    ImageSectionWidget(controller: imageController),
                    Text(
                      "GET HANDWRITTEN NOTES",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lightModeController.isLightMode.value? Colors.black : Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    ImageSectionWidgetTwo(controller: imageController),
                    Text(
                      "SELL YOUR NOTES",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lightModeController.isLightMode.value? Colors.black : Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    ImageSectionWidgetThree(controller: imageController),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: lightModeController.isLightMode.value ? AppConstants.darkContainerColor : AppConstants.lightContainerColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Can’t Find what your Looking For?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: lightModeController.isLightMode.value ? AppConstants.lightContainerColor : AppConstants.darkContainerColor,
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: 350,
                              child: ButtonWidgets(
                                onTap: () {},
                                buttonText: 'Make a request !',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}






