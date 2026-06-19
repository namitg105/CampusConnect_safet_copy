import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repos/auth_repo.dart';
import './google_auth_service.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //attempt sign in
      print("Attempting Firebase login...");
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      print("Firebase login successful");

//before when we created our AppUsser ,we only had userid and email , but now we have the profile info for the user ,
//so we fetch that aslo

      //once we are signed in , create our user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: '',
      );

      //return Appuser
      return user;
    }
    //catch any errors
    catch (e) {
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
      //attempt sign up
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      //once we are signed up , create our user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      //return Appuser
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
    //return AppUser? because maybe no user is logged in.

    try {
      //get currently logged in user from firebase
      final currentFirebaseUser = firebaseAuth.currentUser;

      //no user logged in
      if (currentFirebaseUser == null) {
        return null;
      }

      // user exists
      return AppUser(
        uid: currentFirebaseUser.uid,
        email: currentFirebaseUser.email!,
        name: '',
      );
    } catch (e) {
      throw Exception('Get current user failed: $e');
    }
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    final firebaseUser = await _googleAuthService.signInWithGoogle();

    if (firebaseUser != null) {
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Google User',
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
