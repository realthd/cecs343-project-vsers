import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get user => _auth.currentUser;

  get uid => user.uid;
  bool isAdmin = false;
  final _userController = StreamController<User?>.broadcast();

  AuthenticationHelper() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserRole();
      }
      _userController.add(user);
    });
  }
  Stream<User?> get userStream => _userController.stream;

  // Creates a new user with email and password
  Future<Map<String, dynamic>> signIn({required String email, required String password}) async {
    try {
      // Sign in the user
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _saveLoginState();

      // Fetch the user's role from Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      bool isAdmin = false;
      if (doc.exists) {
        isAdmin = doc.get('isAdmin') ?? false;
      }

      // Return null error and the isAdmin flag
      return {'error': null, 'isAdmin': isAdmin};
    } on FirebaseAuthException catch (e) {
      // Return the error message and default isAdmin to false
      return {'error': e.message, 'isAdmin': false};
    }
  }

  // Modify the signUp method to include the isAdmin flag
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String firstname,
    required String lastname,
    required String password,
    required String username,
    bool isAdmin = false,
  }) async {
    try {
      // Create a new user
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore with the isAdmin flag
      await _createUserDocument(username: username, firstname: firstname, lastname: lastname, email: email, isAdmin: isAdmin);

      // Return null error and the isAdmin flag
      return {'error': null, 'isAdmin': isAdmin};
    } on FirebaseAuthException catch (e) {
      // Return the error message and default isAdmin to false
      return {'error': e.message, 'isAdmin': false};
    }
  }

  Future<void> fetchUserRole() async{
    await _fetchUserRole();
  }
  // Fetch the user's role from Firestore
  Future<void> _fetchUserRole() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        isAdmin = doc.get('isAdmin');
      } else {
        isAdmin = false;
      }
      // Save isAdmin status in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', isAdmin);
    } catch (e) {
      isAdmin = false;
      // Save default isAdmin status in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', false);
    }
  }


  // Modify the _createUserDocument to include isAdmin
  Future<void> _createUserDocument({
    required String username,
    required String firstname,
    required String lastname,
    required String email,
    bool isAdmin = false, // Add this parameter
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final userData = {
      'username': username,
      'email': email,
      'isAdmin': isAdmin,
      'firstname': firstname,
      'lastname': lastname,
      'dateJoined': DateTime.now().millisecondsSinceEpoch / 1000,
    };
    await userDoc.set(userData);
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Null means success
    } catch (e) {
      return e.toString(); // Return error message in case of failure
    }
  }
  String getUID() {
    return user.uid;
  }
  Stream<User?> userChanges() {
    return _auth.authStateChanges();
  }
  // Sign in method

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }
  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear login state and isAdmin flag from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset the isAdmin flag
      this.isAdmin = false;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);

        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user authentication account
        await user.delete();
        await _clearLoginState();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
    }
    return false;
  }


}
