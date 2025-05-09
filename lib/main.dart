import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vsers/authentication/AuthGate.dart';
import 'firebase_options.dart'; // Generated by FlutterFire CLI

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Or your preferred theme color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthGate(), // Use AuthGate to check login state
      debugShowCheckedModeBanner: false,
    );
  }
}