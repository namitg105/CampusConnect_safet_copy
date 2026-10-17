import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noteswap/features/notification_badge/presentation/bloc/notification_badge_bloc.dart';
import '../../Constents/AppConstents.dart';

/// One icon of the legacy bottom bar.
class BottomNavItemWidget extends StatelessWidget {
  final String assetPath;
  final bool isSelected;

  /// Shows the red unread-notifications dot (notifications tab).
  final bool showUnreadDot;

  const BottomNavItemWidget({
    super.key,
    required this.assetPath,
    required this.isSelected,
    this.showUnreadDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = showUnreadDot &&
        context.watch<NotificationBadgeBloc>().state.hasUnread;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(
          assetPath,
          height: 32,
          width: 32,
          colorFilter: ColorFilter.mode(
            isSelected ? AppConstants.dotActiveColor : AppConstants.navColor,
            BlendMode.srcIn,
          ),
        ),
        if (hasUnread)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
