import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Widgets/BottonBar/BottomBar.dart';
import '../Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import '../Services/ImagePicker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import 'package:noteswap/features/theme/presentation/bloc/theme_bloc.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/Buttons/ButtonWidgets.dart';
import '../Widgets/Profile/CustomTextFild.dart';
import '../Widgets/ProfileAvatar.dart';

class AddUsers extends StatelessWidget {
  AddUsers({Key? key}) : super(key: key);

  final ImagePickerService imagePickerService = Get.put(ImagePickerService());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: context.isLightMode ? Colors.black : Colors.white,
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
                      context.isLightMode
                          ? Icons.wb_sunny_outlined
                          : Icons.nightlight_round,
                      color: context.isLightMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () => context.read<ThemeBloc>().add(const ThemeToggled()),
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
                        isDarkMode: context.isLightMode,
                      ),
                      CustomTextField(
                        label: "Room No",
                        isDarkMode: context.isLightMode,
                      ),
                      CustomTextField(
                        label: "Department",
                        isDarkMode: context.isLightMode,
                      ),
                      CustomTextField(
                        label: "Specialization",
                        isDarkMode: context.isLightMode,
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
