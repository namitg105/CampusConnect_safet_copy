import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Widgets/BottonBar/BottomBar.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../Services/ImagePicker.dart';
import '../ViewModels/DarkModeViewModels.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/Buttons/ButtonWidgets.dart';
import '../Widgets/Profile/CustomTextFild.dart';
import '../Widgets/ProfileAvatar.dart';

class AddUsers extends StatelessWidget {
  AddUsers({Key? key}) : super(key: key);

  final LightModeController lightModeController = Get.put(LightModeController());
  final ImagePickerService imagePickerService = Get.put(ImagePickerService());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: lightModeController.isLightMode.value ? Colors.black : Colors.white,
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      lightModeController.isLightMode.value
                          ? Icons.wb_sunny_outlined
                          : Icons.nightlight_round,
                      color: lightModeController.isLightMode.value
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: lightModeController.toggleLightMode,
                  ),
                ),
                ProfileAvatar(
                  onCameraTap: () {},
                  imagePath: imagePickerService.imageFile.value?.path ??
                      AppConstants.defaultProfileImage,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: "Name",
                        isDarkMode: lightModeController.isLightMode.value,
                      ),
                      CustomTextField(
                        label: "Room No",
                        isDarkMode: lightModeController.isLightMode.value,
                      ),
                      CustomTextField(
                        label: "Department",
                        isDarkMode: lightModeController.isLightMode.value,
                      ),
                      CustomTextField(
                        label: "Specialization",
                        isDarkMode: lightModeController.isLightMode.value,
                      ),
                      const SizedBox(height: 20),
                      ButtonWidgets(onTap: () {}, buttonText: 'Save'),
                      const SizedBox(height: 10),
                      ButtonWidgets(onTap: () {}, buttonText: 'Log Out'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
