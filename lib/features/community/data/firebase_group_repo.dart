import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/group.dart';
import '../domain/repos/group_repo.dart';

class FirebaseGroupRepo implements GroupRepo {
  final FirebaseFirestore firestore;

  FirebaseGroupRepo(this.firestore);

  static const int maxMembers = 50;

  @override
  Stream<List<Group>> getGroups() {
    return firestore.collection('groups').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Group.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> createGroup(Group group) async {
    final data = group.toMap();

    data['memberCount'] = 0;
    data['maxMembers'] = maxMembers;
    data['remainingSeats'] = maxMembers;
    data['createdAt'] = FieldValue.serverTimestamp();

    // Add these fields
    data['createdBy'] = group.createdBy;
    data['imageUrl'] = group.imageUrl ?? "";

    final docRef = await firestore.collection('groups').add(data);

    // Optionally add the creator as the first member
    await joinGroup(docRef.id, group.createdBy);
  }

  @override
  Future<void> joinGroup(
    String groupId,
    String userId,
  ) async {
    await firestore.runTransaction((transaction) async {
      final groupRef = firestore.collection('groups').doc(groupId);

      final memberRef = groupRef.collection('members').doc(userId);

      final joinedGroupRef = firestore
          .collection('users')
          .doc(userId)
          .collection('joinedGroups')
          .doc(groupId);

      final memberSnapshot = await transaction.get(memberRef);

      if (memberSnapshot.exists) {
        throw Exception('Already joined');
      }

      final groupSnapshot = await transaction.get(groupRef);

      if (!groupSnapshot.exists) {
        throw Exception('Group not found');
      }

      final data = groupSnapshot.data()!;

      final memberCount = (data['memberCount'] ?? 0) as int;
      final max = (data['maxMembers'] ?? maxMembers) as int;

      if (memberCount >= max) {
        throw Exception('Group is full');
      }

      transaction.set(memberRef, {
        'uid': userId,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(joinedGroupRef, {
        'joinedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(groupRef, {
        'memberCount': FieldValue.increment(1),
        'remainingSeats': FieldValue.increment(-1),
      });
    });
  }

  @override
  Future<void> leaveGroup(
    String groupId,
    String userId,
  ) async {
    await firestore.runTransaction((transaction) async {
      final groupRef = firestore.collection('groups').doc(groupId);

      final memberRef = groupRef.collection('members').doc(userId);

      final joinedGroupRef = firestore
          .collection('users')
          .doc(userId)
          .collection('joinedGroups')
          .doc(groupId);

      final memberSnapshot = await transaction.get(memberRef);

      if (!memberSnapshot.exists) {
        throw Exception('User is not a member of this group');
      }

      transaction.delete(memberRef);

      transaction.delete(joinedGroupRef);

      transaction.update(groupRef, {
        'memberCount': FieldValue.increment(-1),
        'remainingSeats': FieldValue.increment(1),
      });
    });
  }

  @override
  Stream<List<Group>> getJoinedGroups(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('joinedGroups')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Group> groups = [];

      for (final doc in snapshot.docs) {
        final groupDoc = await firestore.collection('groups').doc(doc.id).get();

        if (groupDoc.exists) {
          groups.add(
            Group.fromMap(
              groupDoc.id,
              groupDoc.data()!,
            ),
          );
        }
      }

      return groups;
    });
  }
}
