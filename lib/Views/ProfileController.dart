import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userName = ''.obs;
  var userBio = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Fallback: Check FirebaseAuth displayName first
        if (currentUser.displayName != null &&
            currentUser.displayName!.isNotEmpty) {
          userName.value = currentUser.displayName!;
        }

        // Fetch user document from Firestore 'users' collection
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            userName.value = data['name'] ?? data['userName'] ?? userName.value;
            userBio.value = data['bio'] ?? '';
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
