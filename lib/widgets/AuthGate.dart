import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vsers/widgets/LoginPage.dart';
import '../user/userDashboard.dart'; // Your main user screen after login

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginScreen(); // Show login screen
        }

        // User is logged in
        // You could potentially check user roles here from Firestore
        // and navigate to AdminDashboard if needed.
        // For now, we directly go to UserDashboard.
        return const UserDashboard(); // Show main user dashboard
      },
    );
  }
}