import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repos/auth_repo.dart';

import './google_auth_service.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Future<AppUser?> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;

      final userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();

      // Create Firestore user if missing
      if (!userDoc.exists) {
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data =
          (await firestore.collection('users').doc(firebaseUser.uid).get())
              .data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: data['name'] ?? '',
      );
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential credential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;

      await firestore.collection('users').doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'name': name,
        'email': email,
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppUser(
        uid: firebaseUser.uid,
        email: email,
        name: name,
      );
    } catch (e) {
      throw Exception("Register failed: $e");
    }
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    try {
      final firebaseUser = await _googleAuthService.signInWithGoogle();

      if (firebaseUser == null) return null;

      final userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data =
          (await firestore.collection('users').doc(firebaseUser.uid).get())
              .data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: data['name'] ?? '',
      );
    } catch (e) {
      throw Exception("Google login failed: $e");
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final userDoc =
          await firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data =
          (await firestore.collection('users').doc(firebaseUser.uid).get())
              .data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: data['name'] ?? '',
      );
    } catch (e) {
      throw Exception("Get current user failed: $e");
    }
  }

  @override
  Future<void> logout() async {
    try {
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
