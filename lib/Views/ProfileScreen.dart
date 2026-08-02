import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import 'package:noteswap/Widgets/TextWidgets.dart';
import '../Constents/AppStyles.dart';
import '../Services/ImagePicker.dart';
import '../ViewModels/DarkModeViewModels.dart';
import '../Widgets/BottonBar/BottomBar.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/NotesCard.dart';
import '../Widgets/ProfileAvatar.dart';
import '../features/home/presentation/pages/main_page.dart';
import 'ProfileController.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ImagePickerService imagePickerService = Get.put(ImagePickerService());
  final LightModeController lightModeController =
      Get.find<LightModeController>();
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLight = lightModeController.isLightMode.value;

      return Scaffold(
        backgroundColor: isLight ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: isLight ? Colors.black : Colors.white,
          leading: BackWidget(
            onTap: () => Get.off(() => const MainPage()),
            imagePath: isLight
                ? AppConstants.backWhiteIcon
                : AppConstants.backBlackIcon,
          ),
          title: Text(
            AppConstants.noteSwapTexts,
            style: AppStyles.textStyleLargeBold,
          ),
          centerTitle: true,
          actions: [
            BackWidget(
              onTap: () {},
              imagePath: isLight
                  ? AppConstants.whiteSettingIcon
                  : AppConstants.blackSettingIcon,
            ),
          ],
        ),
        body: profileController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Profile Header Card
                    Container(
                      height: AppConstants.profileContainerHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isLight ? Colors.black : Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(
                              AppConstants.profileContainerBorderRadius),
                          bottomRight: Radius.circular(
                              AppConstants.profileContainerBorderRadius),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ProfileAvatar(
                            onCameraTap: () {},
                            imagePath:
                                imagePickerService.imageFile.value?.path ??
                                    AppConstants.defaultProfileImage,
                          ),
                          const SizedBox(height: 12),

                          // Dynamic User Name
                          Text(
                            profileController.userName.value.isNotEmpty
                                ? profileController.userName.value
                                : AppConstants.userName,
                            style: AppStyles.textStyleLargeBold,
                          ),
                          const SizedBox(height: 4),

                          // Dynamic Bio
                          Text(
                            profileController.userBio.value.isNotEmpty
                                ? profileController.userBio.value
                                : AppConstants.userBio,
                            style: AppStyles.textStyleMedium,
                          ),
                          const SizedBox(height: 16),

                          // Stats Counter Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppConstants.notesPurchased,
                                style: AppStyles.textStyleSmallBold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppConstants.notesPurchasedLabel,
                                style: AppStyles.textStyleSmall,
                              ),
                              const SizedBox(width: 30),
                              Text(
                                AppConstants.separator,
                                style: AppStyles.textStyleSmallBold,
                              ),
                              const SizedBox(width: 30),
                              Text(
                                AppConstants.notesSold,
                                style: AppStyles.textStyleSmallBold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppConstants.notesSoldLabel,
                                style: AppStyles.textStyleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // User Details Section

                    // Offers Made Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Offers Made",
                            style: AppStyles.offerStyleLarge,
                          ),
                          const SizedBox(height: 12),
                          NoteCard(),
                          const SizedBox(height: 10),
                          NoteCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: BottomNavBar(),
      );
    });
  }
}
