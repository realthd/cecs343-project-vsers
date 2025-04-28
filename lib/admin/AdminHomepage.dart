import 'package:flutter/material.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Homepage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome to the Admin Homepage!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text('Here you can manage and overview user data and more.')
          ],
        ),
      ),
    );
  }
}
