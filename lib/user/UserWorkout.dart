import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A class representing a workout goal.
/// Contains the name, target (e.g., calories or distance), and deadline of the goal.
class WorkoutGoal {
  final String name;
  final String target;  // E.g., "Burn 500 calories" or "Run 5km"
  final DateTime deadline;

  WorkoutGoal({
    required this.name,
    required this.target,
    required this.deadline,
  });
}

class UserWorkout extends StatefulWidget {
  const UserWorkout({super.key});

  @override
  State<UserWorkout> createState() => _UserWorkoutState();
}

class _UserWorkoutState extends State<UserWorkout> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _goalNameController = TextEditingController();
  final _goalTargetController = TextEditingController();
  String? _errorMessage;

  // New: list of workout goals for the user
  List<WorkoutGoal> workoutGoals = [];

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

  // Function to save a new workout (including workout goals)
  void _saveWorkout() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Add workout goal to the list (if present)
        if (_goalNameController.text.isNotEmpty && _goalTargetController.text.isNotEmpty) {
          workoutGoals.add(WorkoutGoal(
            name: _goalNameController.text,
            target: _goalTargetController.text,
            deadline: DateTime.now().add(Duration(days: 7)), // Example: Deadline set to 7 days later
          ));
        }

        // Save workout data along with workout goals
        final workout = {
          'name': _nameController.text,
          'duration': int.parse(_durationController.text),
          'date': DateTime.now(),
          'goals': workoutGoals.map((goal) {
            return {
              'name': goal.name,
              'target': goal.target,
              'deadline': goal.deadline,
            };
          }).toList(),
        };

        // Save to Firestore
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
                  // Workout Name Field
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

                  // Workout Duration Field
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

                  // Error message display
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  // Save Workout Button
                  ElevatedButton(
                    onPressed: _saveWorkout,
                    child: const Text('Save Workout'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section to input workout goal details
            TextField(
              controller: _goalNameController,
              decoration: const InputDecoration(labelText: 'Goal Name (e.g., Burn 500 calories)'),
            ),
            TextField(
              controller: _goalTargetController,
              decoration: const InputDecoration(labelText: 'Goal Target (e.g., 500 kcal or 5km)'),
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
                      final goals = workout['goals'] as List<dynamic>? ?? [];
                      return ListTile(
                        title: Text(workout['name'] ?? 'No name'),
                        subtitle: Text('Duration: ${workout['duration']} min\nGoals: ${goals.isNotEmpty ? goals.map((goal) => goal['name']).join(', ') : 'No goals'}'),
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
