import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vsers/user/UserDashboard.dart';
import 'package:vsers/user/UserHomepage.dart';
import 'package:vsers/components/globals.dart' as globals;

class WorkoutGoalsPage extends StatefulWidget {
  const WorkoutGoalsPage({super.key});

  @override
  State<WorkoutGoalsPage> createState() => _WorkoutGoalsPageState();
}

class _WorkoutGoalsPageState extends State<WorkoutGoalsPage> {
  String? selectedGoal;
  int? selectedDays;
  int? selectedDuration;
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Workout Goals'),
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildGoalSelectionPage(),
          _buildDaysSelectionPage(),
          _buildDurationSelectionPage(),
        ],
      ),
    );
  }

  Widget _buildGoalSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your primary fitness goal?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                RadioListTile(
                  title: const Text('Strength Training'),
                  value: 'strength',
                  groupValue: selectedGoal,
                  onChanged: (value) {
                    setState(() {
                      selectedGoal = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Hypertrophy (Muscle Building)'),
                  value: 'hypertrophy',
                  groupValue: selectedGoal,
                  onChanged: (value) {
                    setState(() {
                      selectedGoal = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Fat Loss'),
                  value: 'fat_loss',
                  groupValue: selectedGoal,
                  onChanged: (value) {
                    setState(() {
                      selectedGoal = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Powerlifting'),
                  value: 'powerlifting',
                  groupValue: selectedGoal,
                  onChanged: (value) {
                    setState(() {
                      selectedGoal = value as String?;
                    });
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: selectedGoal != null
                ? () {
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How many days per week can you commit to working out?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                RadioListTile(
                  title: const Text('2 days'),
                  value: 2,
                  groupValue: selectedDays,
                  onChanged: (value) {
                    setState(() {
                      selectedDays = value as int?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('3 days'),
                  value: 3,
                  groupValue: selectedDays,
                  onChanged: (value) {
                    setState(() {
                      selectedDays = value as int?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('5 days'),
                  value: 5,
                  groupValue: selectedDays,
                  onChanged: (value) {
                    setState(() {
                      selectedDays = value as int?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('7 days'),
                  value: 7,
                  groupValue: selectedDays,
                  onChanged: (value) {
                    setState(() {
                      selectedDays = value as int?;
                    });
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: selectedDays != null
                    ? () {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How long do you prefer each workout session to be?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                RadioListTile(
                  title: const Text('45 minutes'),
                  value: 45,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value as int?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('60 minutes'),
                  value: 60,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value as int?;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('90 minutes'),
                  value: 90,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value as int?;
                    });
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: selectedDuration != null
                    ? () async {
                  try {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                    );

                    // Log user authentication
                    final user = FirebaseAuth.instance.currentUser;
                    print('Current user: ${user?.uid ?? 'null'}');
                    if (user == null) {
                      throw Exception('User not authenticated');
                    }

                    // Log query parameters
                    print(
                        'Querying workouts with: goal=$selectedGoal, duration=$selectedDays, workout_length=$selectedDuration');

                    // Test broad query to check data access
                    QuerySnapshot allWorkouts = await FirebaseFirestore
                        .instance
                        .collection('workouts')
                        .get();
                    print(
                        'Total workouts found: ${allWorkouts.docs.length}');
                    for (var doc in allWorkouts.docs) {
                      print('Workout: ${doc.data()}');
                    }

                    // Query Firestore for the matching workout plan
                    QuerySnapshot querySnapshot = await FirebaseFirestore
                        .instance
                        .collection('workouts')
                        .where('goal', isEqualTo: selectedGoal)
                        .where('duration', isEqualTo: selectedDays)
                        .where('workout_length',
                        isEqualTo: selectedDuration)
                        .get();

                    print(
                        'Query returned ${querySnapshot.docs.length} documents');

                    if (querySnapshot.docs.isNotEmpty) {
                      DocumentSnapshot planDoc = querySnapshot.docs.first;
                      DocumentReference planRef = planDoc.reference;

                      // Log the plan details
                      print('Found plan: ${planDoc.data()}');

                      // Get the current user's document
                      String userId = user.uid;
                      DocumentReference userDoc = FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(userId);

                      // Update the user's document with the plan reference
                      await userDoc.set(
                        {'current_workout_plan': planRef},
                        SetOptions(merge: true),
                      );
                      print(
                          'Updated user document with planRef: ${planRef.path}');

                      // Remove loading indicator
                      if (context.mounted) Navigator.pop(context);

                      // Navigate to the home page
                      if (context.mounted) {
                        globals.isWorkoutGoalsSetup = true;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserDashboard()),
                              (route) => false,
                        );
                      }
                    } else {
                      // Remove loading indicator
                      if (context.mounted) Navigator.pop(context);

                      // Show error message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'No matching workout plan found. Please try again.'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Remove loading indicator
                    if (context.mounted) Navigator.pop(context);

                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                        ),
                      );
                    }
                    print('Error: $e');
                  }
                }
                    : null,
                child: const Text('Finish'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}