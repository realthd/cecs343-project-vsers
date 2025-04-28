import 'package:flutter/material.dart';

class AdminTrain extends StatelessWidget {
  const AdminTrain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Training'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage User Training',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality for assigning workouts
              },
              child: const Text('Assign Workout to User'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add functionality for tracking progress
              },
              child: const Text('Track User Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
