import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

/// A service class that handles all admin-specific database operations.
/// This class provides methods for managing workouts and application settings
/// through Firebase Firestore.
class AdminDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example collections an admin might manage
  late final CollectionReference _workoutsCollection;
  late final CollectionReference _appSettingsCollection;
  // Add other collections as needed

  /// Initializes the AdminDatabaseService and sets up Firestore collection references.
  AdminDatabaseService() {
    _workoutsCollection = _firestore.collection('workouts');
    _appSettingsCollection = _firestore.collection('appSettings');
    // Initialize other collections
  }

  // --- Example Methods for Workouts ---

  /// Adds a new workout to the Firestore database.
  ///
  /// [workoutData] is a Map containing the workout information including:
  /// - exercises: List<Map<String, dynamic>>
  ///
  /// Throws an exception if the operation fails.
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

  /// Returns a stream of all workouts ordered by name.
  ///
  /// The stream emits a new QuerySnapshot whenever the workouts collection
  /// changes in Firestore.
  Stream<QuerySnapshot> getWorkoutsStream() {
    // Example: stream of all workouts, ordered by name
    return _workoutsCollection.orderBy('name').snapshots();
  }

  /// Updates an existing workout in the Firestore database.
  ///
  /// [docId] is the Firestore document ID of the workout to update.
  /// [data] is a Map containing the fields to update.
  ///
  /// Throws an exception if the operation fails.
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

  /// Deletes a workout from the Firestore database.
  ///
  /// [docId] is the Firestore document ID of the workout to delete.
  ///
  /// Throws an exception if the operation fails.
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

  /// Updates application settings in Firestore.
  ///
  /// [settingId] is the ID of the setting to update.
  /// [data] is a Map containing the new setting values.
  /// Uses SetOptions(merge: true) to update only the specified fields.
  ///
  /// Throws an exception if the operation fails.
  Future<void> updateAppSettings(
      String settingId, Map<String, dynamic> data) async {
    // Example: App settings might be stored in a specific document
    try {
      await _appSettingsCollection
          .doc(settingId)
          .set(data, SetOptions(merge: true));
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

  /// Retrieves application settings from Firestore.
  ///
  /// [settingId] is the ID of the setting to retrieve.
  /// Returns null if the setting doesn't exist.
  ///
  /// Throws an exception if the operation fails.
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
