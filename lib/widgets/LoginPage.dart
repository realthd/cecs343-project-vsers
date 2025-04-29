import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase/authentication.dart'; // Import your AuthService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Basic Sign In (replace with your actual implementation)
  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // In a real app, use these controllers
      // For this placeholder, we simulate a login or create a test user
      // Example: Create a test user if none exists
      // IMPORTANT: Replace with actual login logic using _authService.signInWithEmailAndPassword
      await _authService.signInWithEmailAndPassword(
          'test@example.com', // Use test credentials or UI input
          'password123'
      );
      // If sign in is successful, the AuthGate StreamBuilder will handle navigation
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'An error occurred');
      // Attempt to create a test user if login fails (e.g., user not found)
      // REMOVE THIS IN PRODUCTION or use proper sign-up flow
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        print("Attempting to create test user...");
        try {
          await _authService.createUserWithEmailAndPassword(
              'test@example.com',
              'password123'
          );
          print("Test user created. Please try logging in again.");
          setState(() => _errorMessage = 'Test user created. Please try logging in again.');
        } catch (signUpError) {
          print("Failed to create test user: $signUpError");
          setState(() => _errorMessage = 'Login failed. Could not create test user.');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'An unknown error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Fitness App Login', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (e.g., test@example.com)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password (e.g., password123)'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                // onPressed: () {
                //   // Simulate successful login for structure testing
                //   // In a real app, call your authService.signIn(...)
                //   print("Simulating Login...");
                //   // You might need to manually sign in a test user in Firebase Console
                //   // or implement a basic sign-in here if needed for testing flow.
                //   // For now, this button won't actually log in unless you add logic.
                // },
                onPressed: _signIn,
                child: const Text('Sign In / Create Test User'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    await _authService.signOut();
                    print("Signed out");
                  } else {
                    print("No user currently signed in.");
                  }
                },
                child: const Text('Sign Out (if logged in)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}