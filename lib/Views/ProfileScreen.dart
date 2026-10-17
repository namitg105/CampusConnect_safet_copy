import 'package:noteswap/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/core/di/injection.dart';
import 'package:noteswap/features/auth/presentation/current_user.dart';
import 'package:noteswap/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:noteswap/Constents/AppConstents.dart';
import '../Constents/AppStyles.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import '../Widgets/BottonBar/BottomBar.dart';
import '../Widgets/Buttons/BackWidgets.dart';
import '../Widgets/NotesCard.dart';
import '../Widgets/ProfileAvatar.dart';
import '../features/home/presentation/pages/main_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Owned by this screen: the logged-in user's profile.
  final ProfileBloc _profileBloc = sl<ProfileBloc>();

  @override
  void initState() {
    super.initState();
    final uid = context.currentUid;
    if (uid.isNotEmpty) _profileBloc.add(ProfileRequested(uid));
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        builder: (context, profileState) {
      final userName =
          profileState.profile?.name ?? context.currentUser?.name ?? '';
      final userBio = profileState.profile?.bio ?? '';
      final isLight = context.isLightMode;

      return Scaffold(
        backgroundColor: isLight ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: isLight ? Colors.black : Colors.white,
          leading: BackWidget(
            onTap: () => AppNavigator.replace(const MainPage()),
            imagePath: isLight
                ? AppConstants.backWhiteIcon
                : AppConstants.backBlackIcon,
          ),
          title: Text(
            AppConstants.noteSwapTexts,
            style: AppStyles.textStyleLargeBold(context),
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
        body: (profileState.loading && !profileState.loaded)
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
                            imagePath: AppConstants.defaultProfileImage,
                          ),
                          const SizedBox(height: 12),

                          // Dynamic User Name
                          Text(
                            userName.isNotEmpty
                                ? userName
                                : AppConstants.userName,
                            style: AppStyles.textStyleLargeBold(context),
                          ),
                          const SizedBox(height: 4),

                          // Dynamic Bio
                          Text(
                            userBio.isNotEmpty
                                ? userBio
                                : AppConstants.userBio,
                            style: AppStyles.textStyleMedium(context),
                          ),
                          const SizedBox(height: 16),

                          // Stats Counter Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppConstants.notesPurchased,
                                style: AppStyles.textStyleSmallBold(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppConstants.notesPurchasedLabel,
                                style: AppStyles.textStyleSmall(context),
                              ),
                              const SizedBox(width: 30),
                              Text(
                                AppConstants.separator,
                                style: AppStyles.textStyleSmallBold(context),
                              ),
                              const SizedBox(width: 30),
                              Text(
                                AppConstants.notesSold,
                                style: AppStyles.textStyleSmallBold(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppConstants.notesSoldLabel,
                                style: AppStyles.textStyleSmall(context),
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
                            style: AppStyles.offerStyleLarge(context),
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
