import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repos/auth_repo.dart';
import './google_auth_service.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // IMPORTANT: Helper method to extract the college domain from the email.
  // E.g., it turns "namit@vitstudent.ac.in" into "vitstudent.ac.in"
  String _extractCollegeId(String email) {
    if (email.isEmpty || !email.contains('@')) return 'unknown';
    return email.split('@').last.toLowerCase();
  }

  Future<void> _saveUserProfile(AppUser user) async {
    await firestore.collection('users').doc(user.uid).set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      print("Attempting Firebase login...");
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      print("Firebase login successful");

      final AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userCredential.user?.displayName ?? '',
        collegeId: _extractCollegeId(email),
      );

      // Keep the user's college identity stored in Firestore.
      await _saveUserProfile(user);

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

      final AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        collegeId: _extractCollegeId(email),
      );

      // Save the newly registered user profile for college isolation.
      await _saveUserProfile(user);

      return user;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
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

      if (currentFirebaseUser == null) {
        return null;
      }

      final email = currentFirebaseUser.email ?? '';
      final userDoc = await firestore
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return AppUser.fromJson(userData);
      }

      // If no Firestore profile exists yet, build one from auth info and persist it.
      final AppUser user = AppUser(
        uid: currentFirebaseUser.uid,
        email: email,
        name: currentFirebaseUser.displayName ?? '',
        collegeId: _extractCollegeId(email),
      );

      await _saveUserProfile(user);
      return user;
    } catch (e) {
      throw Exception('Get current user failed: $e');
    }
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    final firebaseUser = await _googleAuthService.signInWithGoogle();

    if (firebaseUser != null) {
      final email = firebaseUser.email ?? '';
      final AppUser user = AppUser(
        uid: firebaseUser.uid,
        email: email,
        name: firebaseUser.displayName ?? 'Google User',
        collegeId: _extractCollegeId(email),
      );

      await _saveUserProfile(user);
      return user;
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