/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';

class AddFriendFunction {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<Map<String, bool>> areFriendsOnline(List<String> friendUids) {
    if (friendUids.isEmpty) {
      return Stream.value({});
    }

    // Use whereIn to fetch only the documents of the friends in the list.
    // Note: Firestore 'whereIn' limits arrays to up to 30 items.
    return firestore
        .collection('users')
        .where('uid', whereIn: friendUids)
        .snapshots()
        .map((snapshot) {
      // Create a map of { 'friend_uid' : true/false }
      Map<String, bool> onlineStatuses = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        onlineStatuses[data['uid']] = data['isOnline'] ?? false;
      }

      return onlineStatuses;
    });
  }

  Future<AppUser?> addFriend(String friendUid) async {
    try {
      final currentUid = firebaseAuth.currentUser?.uid;
      if (currentUid == null) throw Exception("User not logged in");

      // Use FieldValue.arrayUnion to append the new UID to the 'friends' array
      await firestore.collection('users').doc(currentUid).update({
        'friends': FieldValue.arrayUnion([friendUid]),
      });

      // Fetch and return the updated user profile
      DocumentSnapshot doc =
          await firestore.collection('users').doc(currentUid).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error adding friend: $e");
      throw Exception('Failed to add friend: $e');
    }
  }
}*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import '../../presentation/Design_By_Opencode_5/chat_request_model.dart';

class AddFriendFunction {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<Map<String, bool>> areFriendsOnline(List<String> friendUids) {
    if (friendUids.isEmpty) {
      return Stream.value({});
    }

    return firestore
        .collection('users')
        .where('uid', whereIn: friendUids)
        .snapshots()
        .map((snapshot) {
      Map<String, bool> onlineStatuses = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        onlineStatuses[data['uid']] = data['isOnline'] ?? false;
      }

      return onlineStatuses;
    });
  }

  /*
  Future<AppUser?> addFriend(AppUser currentUser, String friendUid) async {
    try {
      final currentUid = firebaseAuth.currentUser?.uid;
      if (currentUid == null)
        throw Exception("User not logged in via Firebase Auth");

      DocumentSnapshot friendDoc =
          await firestore.collection('users').doc(friendUid).get();

      if (!friendDoc.exists) {
        throw Exception("Target friend profile not found.");
      }

      AppUser friendUser =
          AppUser.fromJson(friendDoc.data() as Map<String, dynamic>);

      final batch = firestore.batch();

      // 2. Path: /users/{currentUserUid}/friends/{friendUid}
      final currentUserFriendRef = firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(friendUser.uid);

      // 3. Path: /users/{friendUid}/friends/{currentUserUid}
      final friendUserFriendRef = firestore
          .collection('users')
          .doc(friendUser.uid)
          .collection('friends')
          .doc(currentUser.uid);

      // 4. Queue payloads into the batch update
      batch.set(currentUserFriendRef, friendUser.toJson());
      batch.set(friendUserFriendRef, currentUser.toJson());

      // 5. Commit atomically
      await batch.commit();
      print("Friendship written successfully to both subcollections!");

      return currentUser;
    } catch (e) {
      print("Error adding friend: $e");
      throw Exception('Failed to add friend: $e');
    }
  }
  */

  // Inside AddFriendFunction class
  Future<AppUser?> addFriend(String friendUid) async {
    try {
      final currentUid = firebaseAuth.currentUser?.uid;
      if (currentUid == null)
        throw Exception("User not logged in via Firebase Auth");

      // 1. Fetch current user data directly from the verified Firestore document
      DocumentSnapshot currentUserDoc =
          await firestore.collection('users').doc(currentUid).get();

      if (!currentUserDoc.exists) {
        throw Exception(
            "Current user profile doc does not exist in Firestore.");
      }

      AppUser currentUser =
          AppUser.fromJson(currentUserDoc.data() as Map<String, dynamic>);

      // 2. Fetch targeted friend's data
      DocumentSnapshot friendDoc =
          await firestore.collection('users').doc(friendUid).get();

      if (!friendDoc.exists) {
        throw Exception("Target friend profile not found.");
      }

      AppUser friendUser =
          AppUser.fromJson(friendDoc.data() as Map<String, dynamic>);

      final batch = firestore.batch();

      // 3. Define paths
      final currentUserFriendRef = firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(friendUser.uid);

      final friendUserFriendRef = firestore
          .collection('users')
          .doc(friendUser.uid)
          .collection('friends')
          .doc(currentUser.uid);

      // 4. Set both payloads
      batch.set(currentUserFriendRef, friendUser.toJson());
      batch.set(friendUserFriendRef, currentUser.toJson());

      // 5. Atomic write
      await batch.commit();
      print("Friendship written successfully to both subcollections!");

      return currentUser;
    } catch (e) {
      print("Error inside AddFriendFunction: $e");
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final currentUid = firebaseAuth.currentUser?.uid;
    if (currentUid == null) throw Exception("User not logged in");

    DocumentSnapshot currentUserDoc =
        await firestore.collection('users').doc(currentUid).get();
    if (!currentUserDoc.exists) {
      throw Exception("Current user profile not found.");
    }
    final userData = currentUserDoc.data() as Map<String, dynamic>;

    final batch = firestore.batch();

    final incomingRef = firestore
        .collection('users')
        .doc(targetUid)
        .collection('friend_requests')
        .doc(currentUid);

    final outgoingRef = firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .doc(targetUid);

    final requestData = {
      'fromUid': currentUid,
      'fromName': userData['name'] ?? '',
      'fromEmail': userData['email'] ?? '',
      'fromImageURL': userData['ImageURL'] ?? '',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    batch.set(incomingRef, requestData);
    batch.set(outgoingRef, requestData);

    await batch.commit();
  }

  Stream<List<QueryDocumentSnapshot>> getIncomingRequestsStream(
      String currentUid) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fromUid'] != currentUid;
      }).toList();
    });
  }

  Stream<List<QueryDocumentSnapshot>> getSentRequestsStream(String currentUid) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fromUid'] == currentUid;
      }).toList();
    });
  }

  Stream<Set<String>> getSentRequestUidsStream(String currentUid) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fromUid'] == currentUid;
      }).map((doc) => doc.id).toSet();
    });
  }

  Stream<Set<String>> getIncomingRequestUidsStream(String currentUid) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fromUid'] != currentUid;
      }).map((doc) => doc.id).toSet();
    });
  }

  Future<void> acceptFriendRequest(String requesterUid) async {
    final currentUid = firebaseAuth.currentUser?.uid;
    if (currentUid == null) throw Exception("User not logged in");

    DocumentSnapshot currentUserDoc =
        await firestore.collection('users').doc(currentUid).get();
    if (!currentUserDoc.exists) {
      throw Exception("Current user profile not found.");
    }
    AppUser currentUser =
        AppUser.fromJson(currentUserDoc.data() as Map<String, dynamic>);

    DocumentSnapshot requesterDoc =
        await firestore.collection('users').doc(requesterUid).get();
    if (!requesterDoc.exists) {
      throw Exception("Requester profile not found.");
    }
    AppUser requesterUser =
        AppUser.fromJson(requesterDoc.data() as Map<String, dynamic>);

    final batch = firestore.batch();

    batch.set(
      firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(requesterUid),
      requesterUser.toJson(),
    );
    batch.set(
      firestore
          .collection('users')
          .doc(requesterUid)
          .collection('friends')
          .doc(currentUid),
      currentUser.toJson(),
    );

    batch.delete(
      firestore
          .collection('users')
          .doc(currentUid)
          .collection('friend_requests')
          .doc(requesterUid),
    );
    batch.delete(
      firestore
          .collection('users')
          .doc(requesterUid)
          .collection('friend_requests')
          .doc(currentUid),
    );

    await batch.commit();
  }

  Future<void> rejectFriendRequest(String requesterUid) async {
    final currentUid = firebaseAuth.currentUser?.uid;
    if (currentUid == null) throw Exception("User not logged in");

    final batch = firestore.batch();

    batch.update(
      firestore
          .collection('users')
          .doc(currentUid)
          .collection('friend_requests')
          .doc(requesterUid),
      {'status': 'ignored'},
    );

    await batch.commit();
  }

  Future<void> acceptIgnoredRequest(String requesterUid) async {
    final currentUid = firebaseAuth.currentUser?.uid;
    if (currentUid == null) throw Exception("User not logged in");

    final batch = firestore.batch();

    batch.delete(
      firestore
          .collection('users')
          .doc(currentUid)
          .collection('friend_requests')
          .doc(requesterUid),
    );
    batch.delete(
      firestore
          .collection('users')
          .doc(requesterUid)
          .collection('friend_requests')
          .doc(currentUid),
    );

    await batch.commit();

    await addFriend(requesterUid);
  }

  Stream<List<ChatRequest>> getIgnoredRequestsStream(String currentUid) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'ignored')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatRequest.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<AppUser>> getFriendsStream(String currentUid) {
    return firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromJson(doc.data());
      }).toList();
    });
  }

  static Future<void> blockUser(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('blocked_users')
        .doc(targetUid)
        .set({'blockedAt': FieldValue.serverTimestamp()});
  }

  static Future<void> unblockUser(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('blocked_users')
        .doc(targetUid)
        .delete();
  }

  static Stream<Set<String>> getBlockedUidsStream(String currentUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('blocked_users')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }
}
