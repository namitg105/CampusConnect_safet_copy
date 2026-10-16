part of 'notification_badge_bloc.dart';

final class NotificationBadgeState extends Equatable {
  final int unreadCount;
  const NotificationBadgeState({this.unreadCount = 0});

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [unreadCount];
}
