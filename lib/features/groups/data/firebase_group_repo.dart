import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/group.dart';
import '../domain/repos/group_repo.dart';

class FirebaseGroupRepo implements GroupRepo {
  final FirebaseFirestore firestore;

  FirebaseGroupRepo(this.firestore);

  @override
  Stream<List<Group>> getGroups(
    String collegeId,
  ) {
    return firestore
        .collection('groups')
        .where(
          'collegeId',
          isEqualTo: collegeId,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (e) => Group.fromMap(
                  e.id,
                  e.data(),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> createGroup(
    Group group,
  ) async {
    await firestore.collection('groups').add(group.toMap());
  }

  @override
  Future<void> joinGroup(
    String groupId,
    String userId,
  ) async {
    final batch = firestore.batch();

    batch.set(
      firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId),
      {
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      firestore
          .collection('users')
          .doc(userId)
          .collection('joinedGroups')
          .doc(groupId),
      {
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );

    batch.update(
      firestore.collection('groups').doc(groupId),
      {
        'memberCount': FieldValue.increment(1),
      },
    );

    await batch.commit();
  }
}
