import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:noteswap/features/notification_badge/data/datasources/notification_badge_remote_data_source.dart';
import 'package:noteswap/features/notification_badge/data/repositories/notification_badge_repository_impl.dart';
import 'package:noteswap/features/notification_badge/domain/usecases/watch_unread_count.dart';
import 'package:noteswap/features/notification_badge/presentation/bloc/notification_badge_bloc.dart';

/// Lets each test push counts (or errors) like Firestore would.
class FakeBadgeSource implements NotificationBadgeRemoteDataSource {
  final controllers = <String, StreamController<int>>{};

  @override
  Stream<int> watchUnreadCount({required String uid, required String email}) {
    return (controllers[uid] = StreamController<int>()).stream;
  }
}

void main() {
  group('isUnreadForUser', () {
    bool rule(Map<String, dynamic> data) =>
        NotificationBadgeRemoteDataSourceImpl.isUnreadForUser(
          data,
          uid: 'me',
          userDomain: 'nith.ac.in',
        );

    test('read or seen notifications never count', () {
      expect(rule({'recipientId': 'me', 'isRead': true}), isFalse);
      expect(rule({'recipientId': 'me', 'isSeen': true}), isFalse);
    });

    test('direct notifications count only for their recipient', () {
      expect(rule({'recipientId': 'me'}), isTrue);
      expect(rule({'recipientId': 'someone-else'}), isFalse);
    });

    test('broadcasts match by sender email domain first', () {
      expect(rule({'senderEmail': 'Prof@NITH.ac.in '}), isTrue);
      expect(rule({'senderEmail': 'x@other.edu', 'collegeId': 'nith.ac.in'}),
          isFalse);
    });

    test('broadcasts without sender email fall back to collegeId', () {
      expect(rule({'collegeId': 'nith.ac.in'}), isTrue);
      expect(rule({'collegeId': 'other.edu'}), isFalse);
      expect(rule(<String, dynamic>{}), isFalse);
    });
  });

  group('NotificationBadgeBloc', () {
    late FakeBadgeSource source;
    late NotificationBadgeBloc bloc;

    setUp(() {
      source = FakeBadgeSource();
      bloc = NotificationBadgeBloc(
        watchUnreadCount:
            WatchUnreadCount(NotificationBadgeRepositoryImpl(source)),
      );
    });
    tearDown(() => bloc.close());

    test('shows live counts after start', () async {
      bloc.add(const NotificationBadgeStarted(uid: 'me', email: 'me@nith.ac.in'));
      await Future<void>.delayed(Duration.zero);
      source.controllers['me']!
        ..add(3)
        ..add(0);
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const NotificationBadgeState(unreadCount: 3),
          const NotificationBadgeState(unreadCount: 0),
        ]),
      );
    });

    test('keeps the last count when the stream errors', () async {
      bloc.add(const NotificationBadgeStarted(uid: 'me', email: 'me@nith.ac.in'));
      await Future<void>.delayed(Duration.zero);
      source.controllers['me']!
        ..add(2)
        ..addError(Exception('permission-denied'));
      await expectLater(
          bloc.stream, emits(const NotificationBadgeState(unreadCount: 2)));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.unreadCount, 2);
    });

    test('stop clears the badge and ignores the old stream', () async {
      bloc.add(const NotificationBadgeStarted(uid: 'me', email: 'me@nith.ac.in'));
      await Future<void>.delayed(Duration.zero);
      source.controllers['me']!.add(5);
      await expectLater(
          bloc.stream, emits(const NotificationBadgeState(unreadCount: 5)));

      bloc.add(const NotificationBadgeStopped());
      await expectLater(bloc.stream, emits(const NotificationBadgeState()));
      expect(source.controllers['me']!.hasListener, isFalse);
    });

    test('switching users listens to the new user only', () async {
      bloc.add(const NotificationBadgeStarted(uid: 'a', email: 'a@x.in'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const NotificationBadgeStarted(uid: 'b', email: 'b@x.in'));
      await Future<void>.delayed(Duration.zero);
      expect(source.controllers['a']!.hasListener, isFalse);
      source.controllers['b']!.add(7);
      await expectLater(
          bloc.stream, emits(const NotificationBadgeState(unreadCount: 7)));
    });
  });
}
