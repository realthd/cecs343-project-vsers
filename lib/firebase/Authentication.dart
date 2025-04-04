import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print("Signed in successfully: ${userCredential.user?.uid}");
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to sign in: ${e.code} - ${e.message}');
      }
      // Rethrow the exception to be handled in the UI
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during sign in: $e');
      }
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print("User created successfully: ${userCredential.user?.uid}");
      }
      // You might want to save user details to Firestore here
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to create user: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during user creation: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        print("User signed out successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

// Add other auth methods if needed (Google Sign In, Apple Sign In, etc.)
}