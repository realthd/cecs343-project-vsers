import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vsers/authentication/LoginPage.dart';
import 'package:vsers/components/workoutGoals.dart';
import '../user/userDashboard.dart';
import "package:vsers/components/globals.dart" as globals;

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginPage(); // Show login screen
        }

        // User is logged in
        // You could potentially check user roles here from Firestore
        // and navigate to AdminDashboard if needed.
        // For now, we directly go to UserDashboard.
        return !globals.isWorkoutGoalsSetup ? WorkoutGoalsPage() : UserDashboard();
      },
    );
  }
}