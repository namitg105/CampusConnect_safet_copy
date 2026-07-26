import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repos/auth_repo.dart';
import './google_auth_service.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user!;

      await firestore.collection('users').doc(firebaseUser.uid).update({
        'isOnline': true,
      });

      final userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'isOnline': true,
          'isImageExists': false,
          'ImageURL': firebaseUser.photoURL ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data =
          (await firestore.collection('users').doc(firebaseUser.uid).get())
              .data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: data['email'] ?? firebaseUser.email ?? '',
        name: data['name'] ?? '',
        isOnline: data['isOnline'] ?? true,
        isImageExists: data['isImageExists'] ?? false,
        imageURL: data['ImageURL'] ?? '',
        phoneNumber: data['phoneNumber'],
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user!;

      AppUser user = AppUser(
        uid: firebaseUser.uid,
        email: email,
        name: name,
        isOnline: true,
        isImageExists: false,
        imageURL: '',
      );

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'isOnline': true,
        'isImageExists': false,
        'ImageURL': '',
        'profileImage': '',
        'phoneNumber': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final currentUid = firebaseAuth.currentUser?.uid;
      if (currentUid != null) {
        await firestore.collection('users').doc(currentUid).update({
          'isOnline': false,
        });
      }
      await firebaseAuth.signOut();
      await _googleAuthService.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final currentFirebaseUser = firebaseAuth.currentUser;

      if (currentFirebaseUser == null) return null;

      final userDoc = await firestore
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        await firestore
            .collection('users')
            .doc(currentFirebaseUser.uid)
            .set({
          'uid': currentFirebaseUser.uid,
          'name': currentFirebaseUser.displayName ?? '',
          'email': currentFirebaseUser.email ?? '',
          'isOnline': false,
          'isImageExists': false,
          'ImageURL': currentFirebaseUser.photoURL ?? '',
          'profileImage': currentFirebaseUser.photoURL ?? '',
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data =
          (await firestore.collection('users').doc(currentFirebaseUser.uid)
                  .get())
              .data()!;

      return AppUser(
        uid: currentFirebaseUser.uid,
        email: data['email'] ?? currentFirebaseUser.email ?? '',
        name: data['name'] ?? '',
        isOnline: data['isOnline'] ?? false,
        isImageExists: data['isImageExists'] ?? false,
        imageURL: data['ImageURL'] ?? '',
        phoneNumber: data['phoneNumber'],
      );
    } catch (e) {
      throw Exception('Get current user failed: $e');
    }
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    final firebaseUser = await _googleAuthService.signInWithGoogle();

    if (firebaseUser != null) {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'Google User',
          'email': firebaseUser.email ?? '',
          'isOnline': true,
          'isImageExists': false,
          'ImageURL': firebaseUser.photoURL ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .update({'isOnline': true});
      }

      final data =
          (await firestore.collection('users').doc(firebaseUser.uid).get())
              .data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: data['email'] ?? firebaseUser.email ?? '',
        name: data['name'] ?? firebaseUser.displayName ?? 'Google User',
        isOnline: data['isOnline'] ?? true,
        isImageExists: data['isImageExists'] ?? false,
        imageURL: data['ImageURL'] ?? firebaseUser.photoURL ?? '',
        phoneNumber: data['phoneNumber'],
      );
    }
    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}
