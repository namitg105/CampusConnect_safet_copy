import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/group.dart';
import '../models/group_model.dart';

abstract interface class GroupRemoteDataSource {
  Stream<List<GroupModel>> watchGroups();
  Stream<Set<String>> watchJoinedGroupIds(String userId);
  Stream<Set<String>> watchPendingRequestGroupIds(String userId);
  Future<void> createGroup(Group group);
  Future<void> joinGroup(String groupId, String userId);
  Future<void> leaveGroup(String groupId, String userId);
  Future<void> requestToJoin(String groupId, String userId);
  Future<void> cancelJoinRequest(String groupId, String userId);
  Future<String> getGroupAdminId(String groupId);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  static const int maxMembers = 50;

  final FirebaseFirestore firestore;
  const GroupRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _groups =>
      firestore.collection('groups');

  DocumentReference<Map<String, dynamic>> _joinedRef(
          String userId, String groupId) =>
      firestore
          .collection('users')
          .doc(userId)
          .collection('joinedGroups')
          .doc(groupId);

  DocumentReference<Map<String, dynamic>> _requestRef(
          String groupId, String userId) =>
      _groups.doc(groupId).collection('join_requests').doc(userId);

  @override
  Stream<List<GroupModel>> watchGroups() {
    return _groups.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => GroupModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  @override
  Stream<Set<String>> watchJoinedGroupIds(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('joinedGroups')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.id).toSet());
  }

  @override
  Stream<Set<String>> watchPendingRequestGroupIds(String userId) {
    return firestore
        .collectionGroup('join_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => {
              for (final doc in snapshot.docs)
                if (doc.reference.parent.parent?.id != null)
                  doc.reference.parent.parent!.id,
            });
  }

  @override
  Future<void> createGroup(Group group) async {
    final data = GroupModel.toMap(group)
      ..['memberCount'] = 0
      ..['maxMembers'] = maxMembers
      ..['remainingSeats'] = maxMembers
      ..['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _groups.add(data);
    // The creator is the first member.
    await joinGroup(docRef.id, group.createdBy);
  }

  @override
  Future<void> joinGroup(String groupId, String userId) async {
    await firestore.runTransaction((transaction) async {
      final groupRef = _groups.doc(groupId);
      final memberRef = groupRef.collection('members').doc(userId);

      final memberSnapshot = await transaction.get(memberRef);
      if (memberSnapshot.exists) {
        throw const ServerException('Already joined');
      }

      final groupSnapshot = await transaction.get(groupRef);
      if (!groupSnapshot.exists) {
        throw const ServerException('Group not found');
      }

      final data = groupSnapshot.data()!;
      final memberCount = ((data['memberCount'] ?? 0) as num).toInt();
      final max = ((data['maxMembers'] ?? maxMembers) as num).toInt();
      if (memberCount >= max) {
        throw const ServerException('Group is full');
      }

      transaction
        ..set(memberRef, {
          'uid': userId,
          'joinedAt': FieldValue.serverTimestamp(),
        })
        ..set(_joinedRef(userId, groupId), {
          'joinedAt': FieldValue.serverTimestamp(),
        })
        ..update(groupRef, {
          'memberCount': FieldValue.increment(1),
          'remainingSeats': FieldValue.increment(-1),
        });
    });
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    await firestore.runTransaction((transaction) async {
      final groupRef = _groups.doc(groupId);
      final memberRef = groupRef.collection('members').doc(userId);

      final memberSnapshot = await transaction.get(memberRef);
      if (!memberSnapshot.exists) {
        throw const ServerException('User is not a member of this group');
      }

      transaction
        ..delete(memberRef)
        ..delete(_joinedRef(userId, groupId))
        ..update(groupRef, {
          'memberCount': FieldValue.increment(-1),
          'remainingSeats': FieldValue.increment(1),
        });
    });
  }

  @override
  Future<void> requestToJoin(String groupId, String userId) {
    return _requestRef(groupId, userId).set({
      'userId': userId,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancelJoinRequest(String groupId, String userId) =>
      _requestRef(groupId, userId).delete();

  @override
  Future<String> getGroupAdminId(String groupId) async {
    final doc = await _groups.doc(groupId).get();
    final data = doc.data();
    return (data?['createdBy'] ?? data?['adminId'] ?? '').toString().trim();
  }
}
