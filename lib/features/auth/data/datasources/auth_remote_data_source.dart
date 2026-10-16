import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/app_user_model.dart';

/// Talks directly to Firebase Auth, Google Sign-In and the Firestore
/// `users` collection. Throws [ServerException] on any failure.
abstract interface class AuthRemoteDataSource {
  Future<AppUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<AppUserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUserModel?> loginWithGoogle();

  Future<AppUserModel?> getCurrentUser();

  Future<void> logout();

  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      firestore.collection('users').doc(uid);

  /// "namit@nith.ac.in" -> "nith.ac.in"
  String _extractCollegeId(String email) {
    if (email.isEmpty || !email.contains('@')) return 'unknown';
    return email.split('@').last.toLowerCase();
  }

  /// The document written the first time a user is seen.
  Map<String, dynamic> _newUserDoc({
    required String uid,
    required String name,
    required String email,
    required bool isOnline,
    String photoUrl = '',
  }) {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'collegeId': _extractCollegeId(email),
      'isOnline': isOnline,
      'isImageExists': false,
      'ImageURL': photoUrl,
      'profileImage': photoUrl,
      'phoneNumber': null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Builds the model from a `users/{uid}` document, filling gaps with
  /// values we already know from Firebase Auth.
  AppUserModel _toModel(
    String uid,
    Map<String, dynamic> data, {
    required String email,
    required bool isOnline,
    String name = '',
    String imageUrl = '',
  }) {
    return AppUserModel(
      uid: uid,
      email: data['email'] ?? email,
      name: data['name'] ?? name,
      collegeId: data['collegeId'] ?? _extractCollegeId(email),
      isOnline: data['isOnline'] ?? isOnline,
      isImageExists: data['isImageExists'] ?? false,
      imageURL: data['ImageURL'] ?? imageUrl,
      phoneNumber: data['phoneNumber'],
    );
  }

  /// Turns Firebase errors into a readable [ServerException].
  ServerException _toServerException(Object e, String prefix) {
    final text = e.toString();
    if ((e is FirebaseAuthException && e.code == 'network-request-failed') ||
        text.contains('network-request-failed') ||
        text.contains('UnknownHostException')) {
      return const ServerException(
          'Network error: Please check your internet connection and try again.');
    }
    if (e is FirebaseAuthException && e.message != null) {
      return ServerException('$prefix: ${e.message}');
    }
    return ServerException('$prefix: $text');
  }

  @override
  Future<AppUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;
      final docRef = _userDoc(firebaseUser.uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        await docRef.update({'isOnline': true});
        return _toModel(
          firebaseUser.uid,
          {...snapshot.data()!, 'isOnline': true},
          email: email,
          isOnline: true,
          name: firebaseUser.displayName ?? '',
        );
      }

      // First login for an account that has no Firestore profile yet.
      var name = firebaseUser.displayName ?? '';
      if (name.isEmpty && email.contains('@')) name = email.split('@').first;
      final newDoc = _newUserDoc(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        isOnline: true,
        photoUrl: firebaseUser.photoURL ?? '',
      );
      await docRef.set(newDoc);
      return _toModel(firebaseUser.uid, newDoc, email: email, isOnline: true);
    } catch (e) {
      throw _toServerException(e, 'Login failed');
    }
  }

  @override
  Future<AppUserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final newDoc =
          _newUserDoc(uid: uid, name: name, email: email, isOnline: true);
      await _userDoc(uid).set(newDoc);
      return _toModel(uid, newDoc, email: email, isOnline: true);
    } catch (e) {
      throw _toServerException(e, 'Register failed');
    }
  }

  @override
  Future<AppUserModel?> loginWithGoogle() async {
    try {
      // Sign out first so the account picker is always shown.
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user closed the picker

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;
      if (firebaseUser == null) return null;

      final email = firebaseUser.email ?? '';
      final collegeId = _extractCollegeId(email);
      final docRef = _userDoc(firebaseUser.uid);
      final snapshot = await docRef.get();

      final Map<String, dynamic> data;
      if (snapshot.exists) {
        await docRef.update({'isOnline': true, 'collegeId': collegeId});
        data = {...snapshot.data()!, 'isOnline': true, 'collegeId': collegeId};
      } else {
        data = _newUserDoc(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Google User',
          email: email,
          isOnline: true,
          photoUrl: firebaseUser.photoURL ?? '',
        );
        await docRef.set(data);
      }

      return _toModel(
        firebaseUser.uid,
        data,
        email: email,
        isOnline: true,
        name: firebaseUser.displayName ?? 'Google User',
        imageUrl: firebaseUser.photoURL ?? '',
      );
    } catch (e) {
      final text = e.toString();
      if (text.contains('10:') || text.contains('ApiException: 10')) {
        throw const ServerException(
            'Google Sign-In failed: Please ensure SHA-1 fingerprint is added in your Firebase Console.');
      }
      throw _toServerException(e, 'Google Sign-In failed');
    }
  }

  @override
  Future<AppUserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final email = firebaseUser.email ?? '';
      final docRef = _userDoc(firebaseUser.uid);
      final snapshot = await docRef.get();

      var data = snapshot.data();
      if (!snapshot.exists || data == null) {
        data = _newUserDoc(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: email,
          isOnline: false,
          photoUrl: firebaseUser.photoURL ?? '',
        );
        await docRef.set(data);
      }

      return _toModel(firebaseUser.uid, data, email: email, isOnline: false);
    } catch (e) {
      throw _toServerException(e, 'Get current user failed');
    }
  }

  @override
  Future<void> logout() async {
    // Each step is best-effort: a failed "isOnline" write must never
    // stop the user from signing out.
    final uid = firebaseAuth.currentUser?.uid;
    if (uid != null) {
      try {
        await _userDoc(uid).update({'isOnline': false});
      } catch (e) {
        debugPrint('Logout: could not set isOnline=false: $e');
      }
    }
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Logout: Firebase signOut failed: $e');
    }
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Logout: Google signOut failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _toServerException(e, 'Failed to send password reset email');
    }
  }
}
