import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class UserDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;

  UserDatabaseService() {
    _usersCollection = _firestore.collection('users');
  }

  // Example: Add or Update user data (using UID from Auth as document ID)
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).set(data, SetOptions(merge: true)); // merge: true prevents overwriting existing fields
      if (kDebugMode) {
        print("User data set/updated successfully for UID: $uid");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error setting user data: $e");
      }
      rethrow; // Rethrow to handle in calling code if necessary
    }
  }

  // Example: Get user data
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (kDebugMode) {
        print("Fetched user data for UID: $uid. Exists: ${doc.exists}");
      }
      return doc.exists ? doc : null;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user data: $e");
      }
      rethrow;
    }
  }

  // Example: Update specific fields for a user
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
      if (kDebugMode) {
        print("User data updated successfully for UID: $uid");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data: $e");
      }
      rethrow;
    }
  }
  Future<bool> isUserAdmin(String uid) async {
    try {
      DocumentSnapshot? doc = await getUserData(uid);
      if (doc != null && doc.exists) {
        // Check if the 'isAdmin' field exists and is true
        // Use `doc.data() as Map<String, dynamic>` for type safety
        final data = doc.data() as Map<String, dynamic>?; // Cast to map
        // Use .get('fieldName') which can return null, or check data directly
        return data?['isAdmin'] == true; // Returns false if field doesn't exist or is not true
      }
      return false; // User document doesn't exist
    } catch (e) {
      if (kDebugMode) {
        print("Error checking admin status: $e");
      }
      return false; // Return false on error
    }
  }

}