import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';

class MobileUpdate {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AppUser> updatePhoneNumber(String phoneNumber) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(uid).update({
      'phoneNumber': phoneNumber,
    });

    final userDoc = await _firestore.collection('users').doc(uid).get();
    return AppUser.fromJson(userDoc.data() as Map<String, dynamic>);
  }

  Future<String?> getMobileNumber(String targetUID) async {
    final userDoc = await _firestore.collection('users').doc(targetUID).get();
    if (!userDoc.exists) return null;
    return userDoc.data()?['phoneNumber'] as String?;
  }
}
