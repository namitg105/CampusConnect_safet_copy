import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/private_chat/data/private-chat-functions/add_friend_function.dart';
import 'package:noteswap/features/private_chat/domain/repos/chat_controller.dart';

class UserController extends GetxController {
  //final FirebaseAuthRepo _authRepo = FirebaseAuthRepo();
  final AddFriendFunction _addRepo = AddFriendFunction();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var currentUser = Rxn<AppUser>();
  var isLoading = false.obs;

  var fetchedUsers = <AppUser>[].obs;
  var isFetchingUsers = false.obs;

  var friendsList = <AppUser>[].obs;
  var isFetchingFriends = false.obs;

  var friendStatuses = <String, bool>{}.obs;
  var friendOnlineStatuses = false.obs;

  var incomingRequests = <dynamic>[].obs;
  var sentRequests = <dynamic>[].obs;
  var incomingRequestUids = <String>{}.obs;
  var sentRequestUids = <String>{}.obs;
  var ignoredRequests = <dynamic>[].obs;
  var blockedUids = <String>{}.obs;

  StreamSubscription? _friendsSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _incomingRequestsSubscription;
  StreamSubscription? _sentRequestsSubscription;
  StreamSubscription? _sentRequestUidsSubscription;
  StreamSubscription? _incomingRequestUidsSubscription;
  StreamSubscription? _ignoredRequestsSubscription;
  StreamSubscription? _blockedSubscription;

  /*Future<void> appendFriend(String targetFriendUid) async {
    try {
      isLoading.value = true;

      AppUser? updatedUser = await _addRepo.addFriend(targetFriendUid);

      if (updatedUser != null) {
        currentUser.value = updatedUser;
      }
    } finally {
      isLoading.value = false;
    }
  }*/
  /*
  Future<void> appendFriend(String targetFriendUid) async {
    final currentAppUser = currentUser.value;
    if (currentAppUser == null) {
      print("Cannot add friend: Current user state is missing.");
      return;
    }

    try {
      isLoading.value = true;

      // Pass the complete current user model down to establish the relationship maps
      AppUser? updatedUser =
          await _addRepo.addFriend(currentAppUser, targetFriendUid);

      if (updatedUser != null) {
        currentUser.value = updatedUser;
      }
    } catch (e) {
      print("Failed processing appendFriend in controller: $e");
    } finally {
      isLoading.value = false;
    }
  }
  */

  // Inside UserController class
  Future<void> appendFriend(String targetFriendUid) async {
    try {
      isLoading.value = true;

      // No more checking if local copy currentUser.value is null!
      // The service layer handles verification securely using FirebaseAuth instance
      await _addRepo.addFriend(targetFriendUid);
    } catch (e) {
      print("Failed processing appendFriend in controller: $e");
      rethrow; // Sends the error to the UI try/catch block
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<AppUser>> fetchUsersByUids(List<String> uids) async {
    // Edge case: If the incoming list is empty, return an empty list immediately
    if (uids.isEmpty) {
      fetchedUsers.clear();
      return [];
    }

    try {
      isFetchingUsers.value = true;

      // Firestore 'whereIn' matches any document whose 'uid' is inside the provided list.
      // Note: Firestore limits 'whereIn' queries to a maximum of 30 items per chunk.
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('uid', whereIn: uids)
          .get();

      // Convert the Firestore documents back into a clean List of AppUser entities
      List<AppUser> users = querySnapshot.docs.map((doc) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Update the reactive GetX variable so the UI updates automatically
      fetchedUsers.value = users;

      return users;
    } catch (e) {
      print("Error fetching users by UIDs: $e");
      return [];
    } finally {
      isFetchingUsers.value = false;
    }
  }

  void monitorFriendsOnlineStatus(List<String> friendUids) {
    // Cancel previous subscription if it exists
    _statusSubscription?.cancel();
    friendOnlineStatuses.value = true;

    if (friendUids.isEmpty) {
      friendStatuses.clear();
      friendOnlineStatuses.value = false;
      return;
    }

    // 3. Listen to the stream from your AddFriendFunction service
    _statusSubscription = _addRepo.areFriendsOnline(friendUids).listen(
      (statuses) {
        friendStatuses
            .assignAll(statuses); // Updates the reactive map seamlessly
        friendOnlineStatuses.value = false;
      },
      onError: (error) {
        friendOnlineStatuses.value = false;
        print("Error reading online statuses: $error");
      },
    );
  }

  bool isFriendOnline(String friendUid) {
    return friendStatuses[friendUid] ?? false;
  }

  void listenToFriendsList(String currentUid) {
    _friendsSubscription?.cancel();
    isFetchingFriends.value = true;

    _friendsSubscription = _addRepo.getFriendsStream(currentUid).listen(
      (friends) async {
        friendsList.value = friends;

        // Automatically feed the friend UIDs into your existing online status tracker
        final friendUids = friends.map((f) => f.uid).toList();
        await fetchUsersByUids(friendUids);
        monitorFriendsOnlineStatus(friendUids);
        isFetchingFriends.value = false;
      },
      onError: (error) {
        isFetchingFriends.value = false;
        print("Error listening to friends collection: $error");
      },
    );
  }

  Future<void> sendFriendRequest(String targetUid) async {
    try {
      isLoading.value = true;
      await _addRepo.sendFriendRequest(targetUid);
    } catch (e) {
      print("Failed to send friend request: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptRequest(String requesterUid) async {
    try {
      isLoading.value = true;
      await _addRepo.acceptFriendRequest(requesterUid);
    } catch (e) {
      print("Failed to accept request: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectRequest(String requesterUid) async {
    try {
      isLoading.value = true;
      await _addRepo.rejectFriendRequest(requesterUid);
    } catch (e) {
      print("Failed to reject request: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptIgnoredRequest(String requesterUid) async {
    try {
      isLoading.value = true;
      await _addRepo.acceptIgnoredRequest(requesterUid);
    } catch (e) {
      print("Failed to accept ignored request: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void listenToFriendRequests(String currentUid) {
    _incomingRequestsSubscription?.cancel();
    _sentRequestsSubscription?.cancel();
    _sentRequestUidsSubscription?.cancel();
    _incomingRequestUidsSubscription?.cancel();
    _ignoredRequestsSubscription?.cancel();

    _incomingRequestsSubscription =
        _addRepo.getIncomingRequestsStream(currentUid).listen(
      (docs) {
        incomingRequests.value = docs;
      },
      onError: (error) {
        print("Error listening to incoming requests: $error");
      },
    );

    _sentRequestsSubscription =
        _addRepo.getSentRequestsStream(currentUid).listen(
      (docs) {
        sentRequests.value = docs;
      },
      onError: (error) {
        print("Error listening to sent requests: $error");
      },
    );

    _sentRequestUidsSubscription =
        _addRepo.getSentRequestUidsStream(currentUid).listen(
      (uids) {
        sentRequestUids.assignAll(uids);
      },
      onError: (error) {
        print("Error listening to sent request UIDs: $error");
      },
    );

    _incomingRequestUidsSubscription =
        _addRepo.getIncomingRequestUidsStream(currentUid).listen(
      (uids) {
        incomingRequestUids.assignAll(uids);
      },
      onError: (error) {
        print("Error listening to incoming request UIDs: $error");
      },
    );

    _ignoredRequestsSubscription =
        _addRepo.getIgnoredRequestsStream(currentUid).listen(
      (docs) {
        ignoredRequests.value = docs;
      },
      onError: (error) {
        print("Error listening to ignored requests: $error");
      },
    );
  }

  void listenToBlockedUsers(String currentUid) {
    _blockedSubscription =
        AddFriendFunction.getBlockedUidsStream(currentUid).listen(
      (uids) {
        blockedUids.assignAll(uids);
      },
      onError: (error) {
        print("Error listening to blocked users: $error");
      },
    );
  }

  Future<void> blockUser(String targetUid) async {
    await AddFriendFunction.blockUser(targetUid);
  }

  Future<void> unblockUser(String targetUid, String roomId) async {
    await AddFriendFunction.unblockUser(targetUid);
    if (Get.isRegistered<ChatController>()) {
      final chatController = Get.find<ChatController>();
      await chatController.markMessagesAsRead(roomId, targetUid);
    }
  }

  @override
  void onClose() {
    _friendsSubscription?.cancel();
    _statusSubscription?.cancel();
    _incomingRequestsSubscription?.cancel();
    _sentRequestsSubscription?.cancel();
    _sentRequestUidsSubscription?.cancel();
    _incomingRequestUidsSubscription?.cancel();
    _ignoredRequestsSubscription?.cancel();
    _blockedSubscription?.cancel();
    super.onClose();
  }
}
