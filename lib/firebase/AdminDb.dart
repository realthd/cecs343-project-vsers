import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class AdminDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example collections an admin might manage
  late final CollectionReference _workoutsCollection;
  late final CollectionReference _appSettingsCollection;
  // Add other collections as needed

  AdminDatabaseService() {
    _workoutsCollection = _firestore.collection('workouts');
    _appSettingsCollection = _firestore.collection('appSettings');
    // Initialize other collections
  }

  // --- Example Methods for Workouts ---

  Future<void> addWorkout(Map<String, dynamic> workoutData) async {
    try {
      await _workoutsCollection.add(workoutData);
      if (kDebugMode) {
        print("Workout added successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding workout: $e");
      }
      rethrow;
    }
  }

  Stream<QuerySnapshot> getWorkoutsStream() {
    // Example: stream of all workouts, ordered by name
    return _workoutsCollection.orderBy('name').snapshots();
  }

  Future<void> updateWorkout(String docId, Map<String, dynamic> data) async {
    try {
      await _workoutsCollection.doc(docId).update(data);
      if (kDebugMode) {
        print("Workout updated successfully for DOC ID: $docId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating workout: $e");
      }
      rethrow;
    }
  }

  Future<void> deleteWorkout(String docId) async {
    try {
      await _workoutsCollection.doc(docId).delete();
      if (kDebugMode) {
        print("Workout deleted successfully for DOC ID: $docId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting workout: $e");
      }
      rethrow;
    }
  }

  // --- Example Methods for App Settings ---

  Future<void> updateAppSettings(String settingId, Map<String, dynamic> data) async {
    // Example: App settings might be stored in a specific document
    try {
      await _appSettingsCollection.doc(settingId).set(data, SetOptions(merge: true));
      if (kDebugMode) {
        print("App setting '$settingId' updated.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating app setting '$settingId': $e");
      }
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getAppSettings(String settingId) async {
    try {
      DocumentSnapshot doc = await _appSettingsCollection.doc(settingId).get();
      if (kDebugMode) {
        print("Fetched app setting '$settingId'. Exists: ${doc.exists}");
      }
      return doc.exists ? doc : null;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting app setting '$settingId': $e");
      }
      rethrow;
    }
  }

// Add other admin-specific database methods here
}