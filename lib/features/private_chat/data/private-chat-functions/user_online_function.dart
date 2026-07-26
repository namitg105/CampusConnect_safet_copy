import 'package:cloud_firestore/cloud_firestore.dart';

class UserOnlineFunction {
  UserOnlineFunction({required this.target_user});

  final Map<String, dynamic> target_user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocumentSnapshot;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserOnline() {
    _userDocumentSnapshot = _firestore
        .collection('users')
        .doc(target_user['uid'] ?? target_user['id'])
        .snapshots();
    return _userDocumentSnapshot;
  }
}
