import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:noteswap/core/error/failures.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/private_chat/data/datasources/friends_remote_data_source.dart';
import 'package:noteswap/features/private_chat/data/models/private_chat_models.dart';
import 'package:noteswap/features/private_chat/domain/entities/chat_message.dart';
import 'package:noteswap/features/private_chat/domain/entities/chat_room.dart';
import 'package:noteswap/features/private_chat/domain/entities/friend_request.dart';
import 'package:noteswap/features/private_chat/domain/entities/pinned_message.dart';
import 'package:noteswap/features/private_chat/domain/repositories/friends_repository.dart';
import 'package:noteswap/features/private_chat/domain/repositories/private_chat_repository.dart';
import 'package:noteswap/features/private_chat/domain/usecases/friends_usecases.dart';
import 'package:noteswap/features/private_chat/domain/usecases/private_chat_usecases.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/chat_details/chat_details_bloc.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/chat_rooms/chat_rooms_bloc.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:noteswap/features/private_chat/presentation/bloc/friends/friends_bloc.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

AppUser _user(String uid) => AppUser(uid: uid, email: '$uid@x.in', name: 'N$uid');

FriendRequest _request(String uid, {String name = ''}) => FriendRequest(
      fromUid: uid,
      fromName: name,
      fromEmail: '',
      fromImageURL: '',
      status: 'pending',
      timestamp: DateTime(2026),
    );

ChatMessage _msg(String id, {String sender = 'me'}) => ChatMessage(
      messageId: id,
      senderId: sender,
      receiverId: sender == 'me' ? 'friend' : 'me',
      message: 'hi',
      timestamp: DateTime(2026),
    );

// ------------------------------------------------------------- fakes

class FakeFriendsRepo implements FriendsRepository {
  final friends = StreamController<Either<Failure, List<AppUser>>>();
  final online = <List<String>>[];
  final blocked = StreamController<Either<Failure, Set<String>>>();
  final calls = <String>[];
  Either<Failure, String> acceptResult = const Right('Live Name');

  @override
  Stream<Either<Failure, List<AppUser>>> watchFriends(String uid) =>
      friends.stream;

  @override
  Stream<Either<Failure, Map<String, bool>>> watchOnlineStatuses(
      List<String> uids) {
    online.add(uids);
    return Stream.value(Right({for (final u in uids) u: u == 'a'}));
  }

  @override
  Stream<Either<Failure, Set<String>>> watchBlockedUids(String uid) =>
      blocked.stream;

  @override
  Stream<Either<Failure, List<FriendRequest>>> watchIncomingRequests(
          String uid) =>
      Stream.value(Right([_request('r1')]));

  @override
  Stream<Either<Failure, Set<String>>> watchSentRequestUids(String uid) =>
      Stream.value(const Right({'s1'}));

  @override
  Stream<Either<Failure, List<FriendRequest>>> watchIgnoredRequests(
          String uid) =>
      const Stream.empty();

  @override
  Stream<Either<Failure, List<AppUser>>> watchDirectory(String uid) {
    calls.add('directory');
    return Stream.value(Right([_user('d1')]));
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String t) async {
    calls.add('send:$t');
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> acceptRequest(String r) async =>
      acceptResult;

  @override
  Future<Either<Failure, String>> declineRequest(String r) async =>
      const Right('');

  @override
  Future<Either<Failure, String>> acceptIgnoredRequest(String r) async =>
      const Right('Live Name');

  @override
  Future<Either<Failure, void>> blockUser(String t) async {
    calls.add('block:$t');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unblockUser(String t) async {
    calls.add('unblock:$t');
    return const Right(null);
  }
}

class FakeChatRepo implements PrivateChatRepository {
  final messages = StreamController<Either<Failure, List<ChatMessage>>>();
  final calls = <String>[];
  OutgoingMessage? lastSent;
  LocalAttachment? lastAttachment;
  Failure? sendFailure;
  Failure? markReadFailure;
  String? phone;

  @override
  Stream<Either<Failure, List<ChatRoomSummary>>> watchChatRooms(String uid) =>
      const Stream.empty();

  @override
  Future<Either<Failure, String>> getOrCreateRoom(String a, String b) async =>
      Right(ChatRoomSummary.idFor(a, b));

  @override
  Stream<Either<Failure, List<ChatMessage>>> watchMessages(String r) =>
      messages.stream;

  @override
  Stream<Either<Failure, PinnedMessage?>> watchPinned(String r) =>
      Stream.value(const Right(null));

  @override
  Stream<Either<Failure, bool>> watchUserOnline(String uid) =>
      Stream.value(const Right(true));

  @override
  Future<Either<Failure, void>> markAsRead(String r, String uid) async {
    calls.add('read:$r:$uid');
    return markReadFailure != null ? Left(markReadFailure!) : const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendMessage(OutgoingMessage m,
      {LocalAttachment? attachment}) async {
    lastSent = m;
    lastAttachment = attachment;
    return sendFailure != null ? Left(sendFailure!) : const Right(null);
  }

  @override
  Future<Either<Failure, void>> toggleReaction({
    required String roomId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    calls.add('react:$messageId:$emoji');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteMessage(
      String r, ChatMessage m, String uid) async {
    calls.add('delete:${m.messageId}');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> pinMessage(
      String r, ChatMessage m, String uid) async {
    calls.add('pin:${m.messageId}');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unpinMessage(String r) async {
    calls.add('unpin');
    return const Right(null);
  }

  @override
  Future<Either<Failure, RoomDetails>> getRoomDetails(
          String r, String uid) async =>
      const Right(RoomDetails(participantName: 'F', lastMessage: 'last'));

  @override
  Future<Either<Failure, List<String>>> getSharedImages(String r) async =>
      const Right(['img']);

  @override
  Future<Either<Failure, List<SharedFile>>> getSharedDocuments(
          String r) async =>
      const Left(ServerFailure('denied'));

  @override
  Future<Either<Failure, String?>> getPhoneNumber(String uid) async =>
      Right(phone);
}

FriendsBloc _friendsBloc(FakeFriendsRepo f, FakeChatRepo c) => FriendsBloc(
      watchFriends: WatchFriends(f),
      watchOnlineStatuses: WatchOnlineStatuses(f),
      watchBlockedUids: WatchBlockedUids(f),
      watchIncomingRequests: WatchIncomingRequests(f),
      watchSentRequestUids: WatchSentRequestUids(f),
      watchIgnoredRequests: WatchIgnoredRequests(f),
      watchDirectory: WatchDirectory(f),
      sendFriendRequest: SendFriendRequest(f),
      acceptFriendRequest: AcceptFriendRequest(f),
      declineFriendRequest: DeclineFriendRequest(f),
      acceptIgnoredRequest: AcceptIgnoredRequest(f),
      blockUser: BlockUser(f),
      unblockUser: UnblockUser(friends: f, chat: c),
    );

ConversationBloc _conversation(FakeChatRepo c) => ConversationBloc(
      watchRoomMessages: WatchRoomMessages(c),
      watchPinnedMessage: WatchPinnedMessage(c),
      watchUserOnline: WatchUserOnline(c),
      markRoomAsRead: MarkRoomAsRead(c),
      sendPrivateMessage: SendPrivateMessage(c),
      toggleReaction: ToggleReaction(c),
      deletePrivateMessage: DeletePrivateMessage(c),
      pinPrivateMessage: PinPrivateMessage(c),
      unpinPrivateMessage: UnpinPrivateMessage(c),
      getPhoneNumber: GetPhoneNumber(c),
    );

void main() {
  late FakeFriendsRepo friendsRepo;
  late FakeChatRepo chatRepo;
  setUp(() {
    friendsRepo = FakeFriendsRepo();
    chatRepo = FakeChatRepo();
  });

  group('whereIn chunking (>30 friends fix)', () {
    test('splits into groups of at most 30', () {
      final ids = [for (var i = 0; i < 65; i++) 'u$i'];
      final chunks = FriendsRemoteDataSourceImpl.splitForWhereIn(ids);
      expect(chunks.map((c) => c.length), [30, 30, 5]);
      expect(chunks.expand((c) => c), ids);
      expect(FriendsRemoteDataSourceImpl.splitForWhereIn([]), isEmpty);
    });
  });

  group('FriendsBloc', () {
    test('loads friends, their online status, requests and blocks', () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(const FriendsWatchStarted('me'));
      await _settle();
      friendsRepo.friends.add(Right([_user('a'), _user('b')]));
      friendsRepo.blocked.add(const Right({'b'}));
      await _settle();

      final s = bloc.state;
      expect(s.friendsLoaded, isTrue);
      expect(s.friends.map((u) => u.uid), ['a', 'b']);
      expect(friendsRepo.online.last, ['a', 'b']);
      expect(s.isOnline('a'), isTrue);
      expect(s.isOnline('b'), isFalse);
      expect(s.isBlocked('b'), isTrue);
      expect(s.incomingRequestUids, {'r1'});
      expect(s.sentRequestUids, {'s1'});
      await bloc.close();
      expect(friendsRepo.friends.hasListener, isFalse);
    });

    test('a failing friends stream still stops the spinner', () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(const FriendsWatchStarted('me'));
      await _settle();
      friendsRepo.friends.add(const Left(ServerFailure('denied')));
      await _settle();
      expect(bloc.state.friendsLoaded, isTrue);
      await bloc.close();
    });

    test('directory is only fetched when requested, once', () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(const FriendsWatchStarted('me'));
      await _settle();
      expect(friendsRepo.calls, isNot(contains('directory')));
      bloc
        ..add(const DirectoryWatchRequested())
        ..add(const DirectoryWatchRequested());
      await _settle();
      expect(friendsRepo.calls.where((c) => c == 'directory'), hasLength(1));
      expect(bloc.state.directoryLoaded, isTrue);
      await bloc.close();
    });

    test('accept uses the live name, falling back to the request name',
        () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(FriendRequestAccepted(_request('r', name: 'Old')));
      await _settle();
      expect(bloc.state.outcome!.message, 'Live Name is now your friend!');

      friendsRepo.acceptResult = const Right('');
      bloc.add(FriendRequestAccepted(_request('r', name: 'Old')));
      await _settle();
      expect(bloc.state.outcome!.message, 'Old is now your friend!');
      expect(bloc.state.outcomeId, 2);
      await bloc.close();
    });

    test('accept failure is reported as an error', () async {
      friendsRepo.acceptResult = const Left(ServerFailure('offline'));
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(FriendRequestAccepted(_request('r')));
      await _settle();
      expect(bloc.state.outcome!.kind, FriendsOutcomeKind.error);
      expect(bloc.state.outcome!.message, 'Failed to accept: offline');
      await bloc.close();
    });

    test('decline is an info message', () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(FriendRequestDeclined(_request('r', name: 'Sam')));
      await _settle();
      expect(bloc.state.outcome!.kind, FriendsOutcomeKind.info);
      expect(bloc.state.outcome!.message, 'Request from Sam declined');
      await bloc.close();
    });

    test('unblock also marks the room as read for that user', () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(const UserUnblockRequested(
            targetUid: 'x', targetName: 'X', roomId: 'me_x'));
      await _settle();
      expect(friendsRepo.calls, contains('unblock:x'));
      expect(chatRepo.calls, contains('read:me_x:x'));
      expect(bloc.state.outcome!.message, 'X has been unblocked');
      await bloc.close();
    });

    test('unblock still succeeds when the room does not exist', () async {
      chatRepo.markReadFailure = const ServerFailure('not-found');
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(const UserUnblockRequested(
            targetUid: 'x', targetName: 'X', roomId: 'me_x'));
      await _settle();
      expect(bloc.state.outcome!.kind, FriendsOutcomeKind.success);
      await bloc.close();
    });

    test('stop clears everything (logout)', () async {
      final bloc = _friendsBloc(friendsRepo, chatRepo)
        ..add(const FriendsWatchStarted('me'));
      await _settle();
      friendsRepo.friends.add(Right([_user('a')]));
      await _settle();
      bloc.add(const FriendsWatchStopped());
      await _settle();
      expect(bloc.state, const FriendsState());
      expect(friendsRepo.friends.hasListener, isFalse);
      await bloc.close();
    });
  });

  group('ChatRoomsBloc', () {
    test('open request answers only the requester', () async {
      final bloc = ChatRoomsBloc(
        watchChatRooms: WatchChatRooms(chatRepo),
        getOrCreateChatRoom: GetOrCreateChatRoom(chatRepo),
      )..add(const ChatRoomOpenRequested(
          currentUid: 'me', friendUid: 'f', requesterId: 7));
      await _settle();
      expect(bloc.state.roomToOpen,
          const RoomToOpen(roomId: 'f_me', friendUid: 'f', requesterId: 7));
      expect(bloc.state.openId, 1);
      await bloc.close();
    });
  });

  group('ConversationBloc', () {
    Future<ConversationBloc> started() async {
      final bloc = _conversation(chatRepo)
        ..add(const ConversationStarted(
            roomId: 'room', currentUid: 'me', friendUid: 'friend'));
      await _settle();
      return bloc;
    }

    test('start marks read and follows messages and status', () async {
      final bloc = await started();
      chatRepo.messages.add(Right([_msg('1')]));
      await _settle();
      expect(chatRepo.calls, contains('read:room:me'));
      expect(bloc.state.messages, hasLength(1));
      expect(bloc.state.friendOnline, isTrue);
      await bloc.close();
      expect(chatRepo.messages.hasListener, isFalse);
    });

    test('text is trimmed; reply and blocked flag are passed on', () async {
      final bloc = await started();
      bloc.add(ConversationTextSent(
        text: '  hey  ',
        replyTo: _msg('9', sender: 'friend'),
        replyToSenderLabel: 'Friend',
        friendIsBlocked: true,
      ));
      await _settle();
      final sent = chatRepo.lastSent!;
      expect(sent.text, 'hey');
      expect(sent.receiverId, 'friend');
      expect(sent.repliedMessageId, '9');
      expect(sent.repliedMessageSender, 'Friend');
      expect(sent.skipUnreadIncrement, isTrue);
      await bloc.close();
    });

    test('blank text is not sent', () async {
      final bloc = await started();
      bloc.add(const ConversationTextSent(text: '   '));
      await _settle();
      expect(chatRepo.lastSent, isNull);
      await bloc.close();
    });

    test("cannot delete the other person's message (fix)", () async {
      final bloc = await started();
      bloc.add(ConversationMessageDeleted(_msg('theirs', sender: 'friend')));
      await _settle();
      expect(chatRepo.calls, isNot(contains('delete:theirs')));
      expect(bloc.state.error, 'You can delete only your own messages.');

      bloc.add(ConversationMessageDeleted(_msg('mine')));
      await _settle();
      expect(chatRepo.calls, contains('delete:mine'));
      await bloc.close();
    });

    test('photo upload: uploading then done, with the photo label', () async {
      final bloc = await started();
      bloc.add(const ConversationAttachmentSent(
        file: LocalAttachment(path: '/p.jpg', name: 'p.jpg'),
        type: MessageType.image,
        friendIsBlocked: true,
      ));
      await expectLater(
        bloc.stream.map((s) => s.uploadStatus),
        emitsInOrder([UploadStatus.uploading, UploadStatus.done]),
      );
      expect(chatRepo.lastSent!.text, '📷 Photo');
      expect(chatRepo.lastSent!.skipUnreadIncrement, isTrue);
      expect(chatRepo.lastAttachment!.name, 'p.jpg');
      await bloc.close();
    });

    test('failed document upload reports an error', () async {
      chatRepo.sendFailure = const ServerFailure('storage/unauthorized');
      final bloc = await started();
      bloc.add(const ConversationAttachmentSent(
        file: LocalAttachment(path: '/d.pdf', name: 'd.pdf'),
        type: MessageType.doc,
      ));
      await _settle();
      expect(bloc.state.uploadStatus, UploadStatus.failed);
      expect(bloc.state.error, 'Upload failed: storage/unauthorized');
      expect(chatRepo.lastSent!.text, 'd.pdf');
      await bloc.close();
    });

    test('call: no number -> error; number -> dial request', () async {
      final bloc = await started();
      bloc.add(const ConversationCallRequested());
      await _settle();
      expect(bloc.state.error, 'Phone number not set');

      chatRepo.phone = '+911234567890';
      bloc.add(const ConversationCallRequested());
      await _settle();
      expect(bloc.state.dialNumber, '+911234567890');
      expect(bloc.state.dialId, 1);
      await bloc.close();
    });

    test('react, pin and unpin go to the repository', () async {
      final bloc = await started();
      bloc
        ..add(ConversationReactionToggled(_msg('1'), '❤️'))
        ..add(ConversationMessagePinned(_msg('1')))
        ..add(const ConversationUnpinned());
      await _settle();
      expect(chatRepo.calls, containsAll(['react:1:❤️', 'pin:1', 'unpin']));
      await bloc.close();
    });
  });

  test('ChatDetailsBloc shows empty documents when loading fails', () async {
    final bloc = ChatDetailsBloc(
      getRoomDetails: GetRoomDetails(chatRepo),
      getSharedImages: GetSharedImages(chatRepo),
      getSharedDocuments: GetSharedDocuments(chatRepo),
    )..add(const ChatDetailsStarted(roomId: 'r', currentUid: 'me'));
    await _settle();
    expect(bloc.state.details!.lastMessage, 'last');
    expect(bloc.state.images, ['img']);
    expect(bloc.state.documentsLoaded, isTrue);
    expect(bloc.state.documents, isEmpty);
    await bloc.close();
  });

  group('models', () {
    test('ChatRoomModel reads per-user unread counters', () {
      final room = ChatRoomModel.fromJson('a_b', {
        'participants': ['a', 'b'],
        'lastMessage': 'yo',
        'unreadCount_a': 3,
      });
      expect(room.unreadFor('a'), 3);
      expect(room.unreadFor('b'), 0);
      expect(room.lastMessage, 'yo');
    });

    test('ChatMessageModel tolerates a pending server timestamp', () {
      final m = ChatMessageModel.fromJson(
          {'senderId': 'a', 'type': 'image', 'timestamp': null}, 'm1');
      expect(m.type, MessageType.image);
      expect(m.timestamp, isA<DateTime>());
      expect(m.reactions, isEmpty);
    });

    test('room ids are the sorted uids', () {
      expect(ChatRoomSummary.idFor('zed', 'amy'), 'amy_zed');
    });
  });
}
