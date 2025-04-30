import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vsers/authentication/LoginPage.dart';
import 'package:vsers/components/workoutGoals.dart';
import '../user/userDashboard.dart';
import "package:vsers/components/globals.dart" as globals;

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Update workout goals status when auth state changes
    _checkWorkoutGoals();
  }

  Future<void> _checkWorkoutGoals() async {
    await globals.updateWorkoutGoalsSetup();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Handle connection state or initial loading
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error checking authentication')),
          );
        }

        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // User is logged in, navigate based on workout plan status
        return globals.isWorkoutGoalsSetup
            ? const UserDashboard()
            : const WorkoutGoalsPage();
      },
    );
  }
}