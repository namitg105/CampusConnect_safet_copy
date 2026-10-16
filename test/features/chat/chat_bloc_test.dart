import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:noteswap/core/error/failures.dart';
import 'package:noteswap/features/chat/data/models/message_model.dart';
import 'package:noteswap/features/chat/domain/entities/message.dart';
import 'package:noteswap/features/chat/domain/repos/chat_repo.dart';
import 'package:noteswap/features/chat/domain/usecases/chat_usecases.dart';
import 'package:noteswap/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:noteswap/features/security/aes_service.dart';

Message _msg(String id) => Message(
      id: id,
      senderId: 'u1',
      senderName: 'U',
      text: 'hi $id',
      type: 'text',
      createdAt: DateTime(2026),
    );

class FakeChatRepo implements ChatRepo {
  final messages = StreamController<Either<Failure, List<Message>>>();
  final calls = <String>[];
  Failure? fail;
  Completer<void>? uploadGate;

  Either<Failure, void> _result() =>
      fail != null ? Left(fail!) : const Right(null);

  @override
  Stream<Either<Failure, List<Message>>> watchMessages(String g) =>
      messages.stream;

  @override
  Future<Either<Failure, void>> sendText(String g, String text) async {
    calls.add('text:$text');
    return _result();
  }

  @override
  Future<Either<Failure, void>> sendMedia(
      String g, MediaKind kind, ChatAttachment file) async {
    calls.add('media:${kind.name}:${file.name}');
    await uploadGate?.future;
    return _result();
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String g, String m) async {
    calls.add('delete:$m');
    return _result();
  }

  @override
  Future<Either<Failure, void>> pinMessage(String g, String m) async {
    calls.add('pin:$m');
    return _result();
  }

  @override
  Future<Either<Failure, void>> unpinMessage(String g) async {
    calls.add('unpin');
    return _result();
  }
}

ChatBloc _bloc(FakeChatRepo r) => ChatBloc(
      watchMessages: WatchMessages(r),
      sendTextMessage: SendTextMessage(r),
      sendMediaMessage: SendMediaMessage(r),
      deleteMessage: DeleteMessage(r),
      pinMessage: PinMessage(r),
      unpinMessage: UnpinMessage(r),
    );

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakeChatRepo repo;
  setUp(() => repo = FakeChatRepo());

  test('loading, then live messages', () async {
    final bloc = _bloc(repo)..add(const ChatWatchStarted('g'));
    await _settle();
    expect(bloc.state.status, ChatStatus.loading);
    repo.messages.add(Right([_msg('1'), _msg('2')]));
    await _settle();
    expect(bloc.state.status, ChatStatus.loaded);
    expect(bloc.state.messages.map((m) => m.id), ['1', '2']);
    await bloc.close();
    expect(repo.messages.hasListener, isFalse);
  });

  test('a failed delete keeps the list and reports the error', () async {
    final bloc = _bloc(repo)..add(const ChatWatchStarted('g'));
    await _settle();
    repo.messages.add(Right([_msg('1')]));
    await _settle();

    repo.fail = const ServerFailure('permission-denied');
    bloc.add(const ChatMessageDeleted(groupId: 'g', messageId: '1'));
    await _settle();
    expect(bloc.state.status, ChatStatus.loaded);
    expect(bloc.state.messages, hasLength(1));
    expect(bloc.state.actionError, 'permission-denied');
    expect(bloc.state.actionErrorId, 1);
    await bloc.close();
  });

  test('pin failure message is prefixed', () async {
    repo.fail = const ServerFailure('offline');
    final bloc = _bloc(repo)
      ..add(const ChatMessagePinned(groupId: 'g', messageId: 'm'));
    await _settle();
    expect(bloc.state.actionError, 'Failed to pin message: offline');
    await bloc.close();
  });

  test('send, delete, pin and unpin reach the repository', () async {
    final bloc = _bloc(repo)
      ..add(const ChatTextSent(groupId: 'g', text: 'hello'))
      ..add(const ChatMessageDeleted(groupId: 'g', messageId: 'm1'))
      ..add(const ChatMessagePinned(groupId: 'g', messageId: 'm2'))
      ..add(const ChatMessageUnpinned('g'));
    await _settle();
    expect(repo.calls,
        containsAll(['text:hello', 'delete:m1', 'pin:m2', 'unpin']));
    expect(bloc.state.actionErrorId, 0);
    await bloc.close();
  });

  test('upload counter stays up until every upload finishes', () async {
    repo.uploadGate = Completer<void>();
    final bloc = _bloc(repo)
      ..add(const ChatMediaSent(
          groupId: 'g',
          kind: MediaKind.image,
          file: ChatAttachment(path: '/a.jpg', name: 'a.jpg')))
      ..add(const ChatMediaSent(
          groupId: 'g',
          kind: MediaKind.document,
          file: ChatAttachment(path: '/b.pdf', name: 'b.pdf', extension: 'pdf')));
    await _settle();
    expect(bloc.state.uploadsInFlight, 2);
    expect(bloc.state.isUploading, isTrue);

    repo.uploadGate!.complete();
    await _settle();
    expect(bloc.state.isUploading, isFalse);
    expect(repo.calls, ['media:image:a.jpg', 'media:document:b.pdf']);
    await bloc.close();
  });

  group('MessageModel', () {
    final aes = AESService();

    test('encrypts text and media url, and decrypts them back', () {
      final message = Message(
        id: '',
        senderId: 'u1',
        senderName: 'U',
        text: 'secret',
        type: 'image',
        mediaUrl: 'https://x/y.jpg',
        createdAt: DateTime(2026, 5, 1, 10, 30),
      );
      final map = MessageModel.toMap(message, aes);
      expect(map['text'], isNot('secret'));
      expect(map['mediaUrl'], isNot('https://x/y.jpg'));

      final back = MessageModel.fromMap('m1', map, aes);
      expect(back.text, 'secret');
      expect(back.mediaUrl, 'https://x/y.jpg');
      expect(back.createdAt, DateTime(2026, 5, 1, 10, 30));
      expect(back.timestamp, back.createdAt);
    });

    test('old plain-text messages are shown as-is', () {
      final back = MessageModel.fromMap(
          'm1', {'text': 'hello there', 'senderId': 'u1'}, aes);
      expect(back.text, 'hello there');
      expect(back.type, 'text');
      expect(back.mediaUrl, isNull);
    });
  });
}
