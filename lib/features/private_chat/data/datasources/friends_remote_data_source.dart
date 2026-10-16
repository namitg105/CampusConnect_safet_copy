import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../models/private_chat_models.dart';

abstract interface class FriendsRemoteDataSource {
  Stream<List<AppUserModel>> watchFriends(String uid);
  Stream<Map<String, bool>> watchOnlineStatuses(List<String> uids);
  Stream<Set<String>> watchBlockedUids(String uid);
  Stream<List<FriendRequestModel>> watchIncomingRequests(String uid);
  Stream<Set<String>> watchSentRequestUids(String uid);
  Stream<List<FriendRequestModel>> watchIgnoredRequests(String uid);
  Stream<List<AppUserModel>> watchDirectory(String uid);
  Future<void> sendFriendRequest(String targetUid);
  Future<String> acceptRequest(String requesterUid);
  Future<String> declineRequest(String requesterUid);
  Future<String> acceptIgnoredRequest(String requesterUid);
  Future<void> blockUser(String targetUid);
  Future<void> unblockUser(String targetUid);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  /// Firestore rejects `whereIn` with more than 30 values.
  static const int whereInLimit = 30;

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const FriendsRemoteDataSourceImpl({required this.firestore, required this.auth});

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _requests(String uid) =>
      _users.doc(uid).collection('friend_requests');

  /// Splits [ids] into groups Firestore accepts in one `whereIn`.
  static List<List<String>> splitForWhereIn(List<String> ids) => [
        for (var i = 0; i < ids.length; i += whereInLimit)
          ids.sublist(i, (i + whereInLimit).clamp(0, ids.length)),
      ];

  String get _currentUid {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw const ServerException('User not logged in');
    return uid;
  }

  Future<AppUserModel> _profile(String uid, String missingMessage) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw ServerException(missingMessage);
    return AppUserModel.fromJson(doc.data()!);
  }

  /// Current display name, falling back to [fallback] when unset.
  Future<String> _liveName(String uid, String fallback) async {
    final doc = await _users.doc(uid).get();
    final name = (doc.data()?['name'] as String?)?.trim();
    return (name != null && name.isNotEmpty) ? name : fallback;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _requestsWithStatus(
          String uid, String status) =>
      _requests(uid).where('status', isEqualTo: status).snapshots();

  @override
  Stream<List<AppUserModel>> watchFriends(String uid) {
    return _users.doc(uid).collection('friends').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => AppUserModel.fromJson(doc.data())).toList());
  }

  @override
  Stream<Map<String, bool>> watchOnlineStatuses(List<String> uids) {
    if (uids.isEmpty) return Stream.value(const {});

    final chunks = splitForWhereIn(uids);

    // One query per chunk; merge their latest results into a single map.
    final latest = List<Map<String, bool>>.filled(chunks.length, const {});
    final subscriptions = <StreamSubscription>[];
    late final StreamController<Map<String, bool>> controller;
    controller = StreamController<Map<String, bool>>(
      onListen: () {
        for (var i = 0; i < chunks.length; i++) {
          subscriptions.add(_users
              .where('uid', whereIn: chunks[i])
              .snapshots()
              .listen((snapshot) {
            latest[i] = {
              for (final doc in snapshot.docs)
                doc.data()['uid'] as String: doc.data()['isOnline'] ?? false,
            };
            controller.add({for (final part in latest) ...part});
          }, onError: controller.addError));
        }
      },
      onCancel: () async {
        for (final s in subscriptions) {
          await s.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Stream<Set<String>> watchBlockedUids(String uid) {
    return _users
        .doc(uid)
        .collection('blocked_users')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  @override
  Stream<List<FriendRequestModel>> watchIncomingRequests(String uid) {
    return _requestsWithStatus(uid, 'pending').map((snapshot) => snapshot.docs
        .where((doc) => doc.data()['fromUid'] != uid)
        .map((doc) => FriendRequestModel.fromJson(doc.data()))
        .toList());
  }

  @override
  Stream<Set<String>> watchSentRequestUids(String uid) {
    return _requestsWithStatus(uid, 'pending').map((snapshot) => snapshot.docs
        .where((doc) => doc.data()['fromUid'] == uid)
        .map((doc) => doc.id)
        .toSet());
  }

  @override
  Stream<List<FriendRequestModel>> watchIgnoredRequests(String uid) {
    return _requestsWithStatus(uid, 'ignored').map((snapshot) => snapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()))
        .toList());
  }

  @override
  Stream<List<AppUserModel>> watchDirectory(String uid) {
    return _users.where('uid', isNotEqualTo: uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => AppUserModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> sendFriendRequest(String targetUid) async {
    final currentUid = _currentUid;
    final currentDoc = await _users.doc(currentUid).get();
    if (!currentDoc.exists) {
      throw const ServerException('Current user profile not found.');
    }
    final userData = currentDoc.data()!;

    // The same request is stored on both sides.
    final requestData = {
      'fromUid': currentUid,
      'fromName': userData['name'] ?? '',
      'fromEmail': userData['email'] ?? '',
      'fromImageURL': userData['ImageURL'] ?? '',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    };
    await (firestore.batch()
          ..set(_requests(targetUid).doc(currentUid), requestData)
          ..set(_requests(currentUid).doc(targetUid), requestData))
        .commit();
  }

  /// Writes the friendship on both sides (each stores a copy of the other).
  Future<void> _addFriendship(String currentUid, String otherUid,
      {bool deleteRequests = false}) async {
    final me = await _profile(currentUid, 'Current user profile not found.');
    final other = await _profile(otherUid, 'Requester profile not found.');

    final batch = firestore.batch()
      ..set(_users.doc(currentUid).collection('friends').doc(otherUid),
          other.toJson())
      ..set(_users.doc(otherUid).collection('friends').doc(currentUid),
          me.toJson());
    if (deleteRequests) {
      batch
        ..delete(_requests(currentUid).doc(otherUid))
        ..delete(_requests(otherUid).doc(currentUid));
    }
    await batch.commit();
  }

  @override
  Future<String> acceptRequest(String requesterUid) async {
    await _addFriendship(_currentUid, requesterUid, deleteRequests: true);
    return _liveName(requesterUid, '');
  }

  @override
  Future<String> declineRequest(String requesterUid) async {
    await _requests(_currentUid).doc(requesterUid).update({'status': 'ignored'});
    return _liveName(requesterUid, '');
  }

  @override
  Future<String> acceptIgnoredRequest(String requesterUid) async {
    final currentUid = _currentUid;
    await (firestore.batch()
          ..delete(_requests(currentUid).doc(requesterUid))
          ..delete(_requests(requesterUid).doc(currentUid)))
        .commit();
    await _addFriendship(currentUid, requesterUid);
    return _liveName(requesterUid, '');
  }

  @override
  Future<void> blockUser(String targetUid) {
    return _users
        .doc(_currentUid)
        .collection('blocked_users')
        .doc(targetUid)
        .set({'blockedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> unblockUser(String targetUid) {
    return _users
        .doc(_currentUid)
        .collection('blocked_users')
        .doc(targetUid)
        .delete();
  }
}
