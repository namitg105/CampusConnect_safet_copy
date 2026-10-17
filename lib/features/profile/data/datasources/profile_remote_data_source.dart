import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/user_profile.dart';

abstract interface class ProfileRemoteDataSource {
  Future<UserProfile?> getProfile(String uid);
  Future<String> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required ProfileImageChange image,
    required String? currentImageUrl,
  });
}

/// `users/{uid}` profile fields + `profile_pictures/{uid}.jpg` in Storage.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  const ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      firestore.collection('users').doc(uid);

  Reference _picture(String uid) =>
      storage.ref().child('profile_pictures/$uid.jpg');

  /// Older documents use other keys for the same data; read all of them.
  static UserProfile fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? map['displayName'] ?? map['userName'],
      email: map['email'],
      bio: map['bio'],
      profileImage: map['profileImage'] ?? map['imageUrl'] ?? map['photoUrl'],
      collegeId: map['collegeId'],
    );
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
      final doc = await _doc(uid).get();
      final data = doc.data();
      return doc.exists && data != null ? fromMap(uid, data) : null;
  }

  @override
  Future<String> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required ProfileImageChange image,
    required String? currentImageUrl,
  }) async {
      var imageUrl = currentImageUrl;
      switch (image) {
        case KeepImage():
          break;
        case ResetImage():
          imageUrl = '';
          try {
            await _picture(uid).delete();
          } catch (_) {
            // Nothing stored yet: fine.
          }
        case ReplaceImage(:final localPath):
          final ref = _picture(uid);
          await ref.putFile(File(localPath));
          imageUrl = await ref.getDownloadURL();
      }

      await _doc(uid).set(
        {'name': name, 'bio': bio, 'profileImage': imageUrl ?? ''},
        SetOptions(merge: true),
      );

      // Best-effort: Firestore is the source of truth.
      try {
        await auth.currentUser?.updateDisplayName(name);
      } catch (_) {}
      return name;
  }
}
