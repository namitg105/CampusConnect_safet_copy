import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/posts/domain/repos/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final FirebaseFirestore firestore;

  ProfileRepoImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
