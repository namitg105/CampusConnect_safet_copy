import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_unread_count.dart';

part 'notification_badge_event.dart';
part 'notification_badge_state.dart';

/// Keeps the unread-notification dot up to date while a user is logged in.
/// Started/stopped from `AuthWrapper` when the auth state changes.
class NotificationBadgeBloc
    extends Bloc<NotificationBadgeEvent, NotificationBadgeState> {
  final WatchUnreadCount _watchUnreadCount;
  StreamSubscription<void>? _subscription;

  NotificationBadgeBloc({required WatchUnreadCount watchUnreadCount})
      : _watchUnreadCount = watchUnreadCount,
        super(const NotificationBadgeState()) {
    on<NotificationBadgeStarted>(_onStarted);
    on<NotificationBadgeStopped>(_onStopped);
    on<_UnreadCountChanged>(
      (event, emit) => emit(NotificationBadgeState(unreadCount: event.count)),
    );
  }

  Future<void> _onStarted(
    NotificationBadgeStarted event,
    Emitter<NotificationBadgeState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _watchUnreadCount(
      WatchUnreadCountParams(uid: event.uid, email: event.email),
    ).listen((result) => result.fold(
          // Keep showing the last known count if the stream errors.
          (failure) => debugPrint('Unread notifications: ${failure.message}'),
          (count) => add(_UnreadCountChanged(count)),
        ));
  }

  Future<void> _onStopped(
    NotificationBadgeStopped event,
    Emitter<NotificationBadgeState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
    emit(const NotificationBadgeState());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
