import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/adminDashboard.dart'; // Import Admin Dashboard
import '../firebase/userDb.dart';      // Import User DB Service
import '../user/userDashboard.dart';    // Import User Dashboard

class RoleDispatcher extends StatefulWidget {
  final User user; // Pass the logged-in user from AuthGate
  const RoleDispatcher({super.key, required this.user});

  @override
  State<RoleDispatcher> createState() => _RoleDispatcherState();
}

class _RoleDispatcherState extends State<RoleDispatcher> {
  final UserDatabaseService _userDb = UserDatabaseService();
  Future<bool>? _isAdminCheck; // Store the future

  @override
  void initState() {
    super.initState();
    // Start the admin check when the widget initializes
    _isAdminCheck = _userDb.isUserAdmin(widget.user.uid);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminCheck,
      builder: (context, snapshot) {
        // Check if the future is still running
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show loading indicator
          );
        }

        // Check for errors during the future execution
        if (snapshot.hasError) {
          print("Error in RoleDispatcher FutureBuilder: ${snapshot.error}");
          // Decide what to do on error - navigate to user dashboard or show error screen
          return const Scaffold(
            body: Center(child: Text("Error loading user role. Please try again.")),
            // Optionally add a sign out button here
          );
          // Or default to UserDashboard on error:
          // return const UserDashboard();
        }

        // Check the result of the future (isAdmin value)
        final bool isAdmin = snapshot.data ?? false; // Default to false if data is null

        if (isAdmin) {
          // If user is admin, navigate to AdminDashboard
          return const AdminDashboard();
        } else {
          // Otherwise, navigate to UserDashboard
          return const UserDashboard();
        }
      },
    );
  }
}