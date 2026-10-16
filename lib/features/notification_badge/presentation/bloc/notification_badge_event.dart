part of 'notification_badge_bloc.dart';

sealed class NotificationBadgeEvent extends Equatable {
  const NotificationBadgeEvent();

  @override
  List<Object?> get props => [];
}

/// A user logged in: start listening for their unread notifications.
final class NotificationBadgeStarted extends NotificationBadgeEvent {
  final String uid;
  final String email;
  const NotificationBadgeStarted({required this.uid, required this.email});

  @override
  List<Object?> get props => [uid, email];
}

/// Logged out: stop listening and clear the badge.
final class NotificationBadgeStopped extends NotificationBadgeEvent {
  const NotificationBadgeStopped();
}

/// Internal: Firestore pushed a new count.
final class _UnreadCountChanged extends NotificationBadgeEvent {
  final int count;
  const _UnreadCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}
