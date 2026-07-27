import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repos/auth_repo.dart';

import './google_auth_service.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // Helper method to extract the college domain from the email.
  String _extractCollegeId(String email) {
    if (email.isEmpty || !email.contains('@')) return 'unknown';
    return email.split('@').last.toLowerCase();
  }

  @override
  Future<AppUser?> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print("Attempting Firebase login...");
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      print("Firebase login successful");

      final firebaseUser = userCredential.user!;

      await firestore.collection('users').doc(firebaseUser.uid).update({
        'isOnline': true,
      });

      final userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();
      String userName = '';
      String collegeId = _extractCollegeId(email);
      bool isOnline = true;
      bool isImageExists = false;
      String imageURL = '';
      String? phoneNumber;

      if (userDoc.exists) {
        final data = userDoc.data()!;
        userName = data['name'] ?? firebaseUser.displayName ?? '';
        collegeId = data['collegeId'] ?? _extractCollegeId(email);
        isOnline = data['isOnline'] ?? true;
        isImageExists = data['isImageExists'] ?? false;
        imageURL = data['ImageURL'] ?? '';
        phoneNumber = data['phoneNumber'];
      } else {
        userName = firebaseUser.displayName ?? '';
        if (userName.isEmpty && email.contains('@')) {
          userName = email.split('@').first;
        }
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': userName,
          'email': email,
          'collegeId': collegeId,
          'isOnline': true,
          'isImageExists': false,
          'ImageURL': firebaseUser.photoURL ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final AppUser user = AppUser(
        uid: firebaseUser.uid,
        email: email,
        name: userName,
        collegeId: collegeId,
        isOnline: isOnline,
        isImageExists: isImageExists,
        imageURL: imageURL,
        phoneNumber: phoneNumber,
      );

      return user;
    } catch (e) {
      print("Firebase login error: $e");
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
      final collegeId = _extractCollegeId(email);

      final AppUser user = AppUser(
        uid: firebaseUser.uid,
        email: email,
        name: name,
        collegeId: collegeId,
        isOnline: true,
        isImageExists: false,
        imageURL: '',
      );

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'collegeId': collegeId,
        'isOnline': true,
        'isImageExists': false,
        'ImageURL': '',
        'profileImage': '',
        'phoneNumber': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      throw Exception("Register failed: $e");
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final currentFirebaseUser = firebaseAuth.currentUser;
      if (currentFirebaseUser == null) return null;

      final email = currentFirebaseUser.email ?? '';
      final userDoc = await firestore
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        final collegeId = _extractCollegeId(email);
        await firestore.collection('users').doc(currentFirebaseUser.uid).set({
          'uid': currentFirebaseUser.uid,
          'name': currentFirebaseUser.displayName ?? '',
          'email': email,
          'collegeId': collegeId,
          'isOnline': false,
          'isImageExists': false,
          'ImageURL': currentFirebaseUser.photoURL ?? '',
          'profileImage': currentFirebaseUser.photoURL ?? '',
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data = (await firestore
              .collection('users')
              .doc(currentFirebaseUser.uid)
              .get())
          .data()!;

      return AppUser(
        uid: currentFirebaseUser.uid,
        email: data['email'] ?? email,
        name: data['name'] ?? '',
        collegeId: data['collegeId'] ?? _extractCollegeId(email),
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
      final email = firebaseUser.email ?? '';
      final collegeId = _extractCollegeId(email);
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'Google User',
          'email': email,
          'collegeId': collegeId,
          'isOnline': true,
          'isImageExists': false,
          'ImageURL': firebaseUser.photoURL ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await firestore.collection('users').doc(firebaseUser.uid).update({
          'isOnline': true,
          'collegeId': collegeId,
        });
      }

      final data =
          (await firestore.collection('users').doc(firebaseUser.uid).get())
              .data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: data['email'] ?? email,
        name: data['name'] ?? firebaseUser.displayName ?? 'Google User',
        collegeId: data['collegeId'] ?? collegeId,
        isOnline: data['isOnline'] ?? true,
        isImageExists: data['isImageExists'] ?? false,
        imageURL: data['ImageURL'] ?? firebaseUser.photoURL ?? '',
        phoneNumber: data['phoneNumber'],
      );
    }
    return null;
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
      throw Exception("Logout failed: $e");
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
    } catch (e) {
      throw Exception("Failed to send password reset email: $e");
    }
  }
}
