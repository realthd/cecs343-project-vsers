import 'package:flutter/material.dart';

class UserHomepage extends StatelessWidget {
  const UserHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
      ),
      body: const Center(
        child: Text(
          'User Homepage Content Goes Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}