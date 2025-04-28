import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserWorkout extends StatelessWidget {
  const UserWorkout({super.key});

  // Method to retrieve past workouts from Firestore
  Future<List<Map<String, dynamic>>> _getWorkouts() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('workouts').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error retrieving workouts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workouts found.'));
          }

          // Display workout data
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final workout = snapshot.data![index];
              return ListTile(
                title: Text(workout['name'] ?? 'No name'),
                subtitle: Text('Duration: ${workout['duration']} min'),
                trailing: Text(workout['date'].toString()),
              );
            },
          );
        },
      ),
    );
  }
}
