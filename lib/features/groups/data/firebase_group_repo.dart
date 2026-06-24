import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/group.dart';
import '../domain/repos/group_repo.dart';

class FirebaseGroupRepo implements GroupRepo {
  final FirebaseFirestore firestore;

  FirebaseGroupRepo(this.firestore);

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
    await firestore.collection('groups').add(
          group.toMap(),
        );
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

      final remainingSeats =
          (groupSnapshot.data()?['remainingSeats'] ?? 0) as int;

      if (remainingSeats <= 0) {
        throw Exception('Group is full');
      }

      transaction.set(memberRef, {
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

  Future<void> leaveGroup(
    String groupId,
    String userId,
  ) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      final memberRef = groupRef.collection('members').doc(userId);

      final joinedGroupRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('joinedGroups')
          .doc(groupId);

      final memberSnapshot = await transaction.get(memberRef);

      // User is not in group
      if (!memberSnapshot.exists) {
        throw Exception('User is not a member of this group');
      }

      // Remove user from group members
      transaction.delete(memberRef);

      // Remove group from user's joined groups
      transaction.delete(joinedGroupRef);

      // Update counts
      transaction.update(groupRef, {
        'memberCount': FieldValue.increment(-1),
        'remainingSeats': FieldValue.increment(1),
      });
    });
  }
}
