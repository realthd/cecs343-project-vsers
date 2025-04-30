library vsers.globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool isWorkingOut = false;
bool isWorkoutGoalsSetup = false;

/// Updates the [isWorkoutGoalsSetup] global variable by checking Firestore.
///
/// This function queries Firestore to determine if the authenticated user has a
/// `current_workout_plan` field in their `users/<userId>` document, and if that
/// reference points to a valid document in the `workouts` collection. It updates
/// the [isWorkoutGoalsSetup] global variable accordingly.
///
/// Returns:
/// - `Future<void>`: Completes when the check is done and [isWorkoutGoalsSetup] is updated.
Future<void> updateWorkoutGoalsSetup() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isWorkoutGoalsSetup = false;
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('current_workout_plan')) {
      isWorkoutGoalsSetup = false;
      return;
    }

    final planRef = userDoc.data()!['current_workout_plan'] as DocumentReference;
    final planDoc = await planRef.get();

    isWorkoutGoalsSetup = planDoc.exists;
  } catch (e) {
    print('Error checking workout plan: $e');
    isWorkoutGoalsSetup = false;
  }
}