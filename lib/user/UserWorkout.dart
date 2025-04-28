import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserWorkout extends StatefulWidget {
  const UserWorkout({super.key});

  @override
  State<UserWorkout> createState() => _UserWorkoutState();
}

class _UserWorkoutState extends State<UserWorkout> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  String? _errorMessage;

  // Function to retrieve past workouts from Firestore
  Future<List<Map<String, dynamic>>> _getWorkouts() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('workouts').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error retrieving workouts: $e');
      return [];
    }
  }

  // Function to save a new workout
  void _saveWorkout() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final workout = {
          'name': _nameController.text,
          'duration': int.parse(_durationController.text),
          'date': DateTime.now(),
        };
        await FirebaseFirestore.instance.collection('workouts').add(workout);
        setState(() {
          _errorMessage = null; // Clear any previous error messages
        });
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        setState(() {
          _errorMessage = 'Error saving workout: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to add a new workout
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Workout Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a workout name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a duration';
                      } else if (int.tryParse(value) == null) {
                        return 'Please enter a valid number for duration';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: _saveWorkout,
                    child: const Text('Save Workout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Displaying list of past workouts
            FutureBuilder<List<Map<String, dynamic>>>(
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
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final workout = snapshot.data![index];
                      return ListTile(
                        title: Text(workout['name'] ?? 'No name'),
                        subtitle: Text('Duration: ${workout['duration']} min'),
                        trailing: Text(workout['date'].toString()),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

