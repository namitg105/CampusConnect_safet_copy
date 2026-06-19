import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/user_profile.dart';
import '../domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firestore;

  FirebaseProfileRepo(
    this.firestore,
  );

  @override
  Future<UserProfile> getProfile(
    String uid,
  ) async {
    final doc = await firestore.collection('users').doc(uid).get();

    return UserProfile.fromMap(
      doc.data()!,
    );
  }
}
