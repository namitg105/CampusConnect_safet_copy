import 'package:get/get.dart';

import './../../../auth/domain/entities/app_user.dart';

// Assuming you already have a User model from your backend setup
class UserService extends GetxService {
  final Rxn<AppUser> _currentUser = Rxn<AppUser>();

  // Getter to easily access the current user
  AppUser? get currentUser => _currentUser.value;

  // Checker to see if a user is logged in
  bool get isLoggedIn => _currentUser.value != null;

  // Call this method inside your existing login/register Cubit success states
  // or during your initial authGate check to seed the data.
  void updateUser(AppUser? user) {
    _currentUser.value = user;
  }

  // Clear user data on logout
  void clearUser() {
    _currentUser.value = null;
  }
}
