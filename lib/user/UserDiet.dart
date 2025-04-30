/// A Flutter widget for displaying a user's daily diet summary,
/// including calorie intake, macronutrient breakdown, and a list of meals.
///
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddMealScreen.dart';
import 'UpdateGoalsScreen.dart';
import '../firebase/DietService.dart';

/// A stateful widget that shows a user's diet summary for the day.
/// Attributes:
/// - key: An optional unique identifier for the widget.

class UserDiet extends StatefulWidget {
  const UserDiet({super.key});

  @override
  State<UserDiet> createState() => _UserDietState();
}

class _UserDietState extends State<UserDiet> {
  final DietService _dietService = DietService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _goals = {};
  Map<String, dynamic> _dailyTotals = {};
  List<Map<String, dynamic>> _meals = [];
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data() ?? {};
        });
      }
    }
  }

  // Helper method to get meal type priority
  int _getMealTypePriority(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      case 'snack':
        return 3;
      default:
        return 4;
    }
  }

  Future<void> _loadData() async {
    final goals = await _dietService.getDietGoals();
    final dailyTotals = await _dietService.getDailyTotals();
    final meals = await _dietService.getTodaysMeals();

    setState(() {
      _goals = goals;
      _dailyTotals = dailyTotals;
      // Sort meals by meal type
      _meals = meals
        ..sort((a, b) => _getMealTypePriority(a['mealType'] ?? 'other')
            .compareTo(_getMealTypePriority(b['mealType'] ?? 'other')));
    });
  }

  /// Builds the UI for the UserDiet screen.
  ///
  /// Args:
  /// - context (BuildContext): The context in which the widget is built.
  ///
  /// Returns:
  /// - Widget: A Scaffold containing the diet overview UI elements.
  ///
  /// Summary:
  /// Constructs the main layout including today's summary, macronutrients,
  /// and today's meals, and returns the assembled Scaffold widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Diet'),
            if (_userData.isNotEmpty)
              Text(
                '${_userData['firstname']} ${_userData['lastname']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card with Macros
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // Calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Calories'),
                        Text(
                            '${_dailyTotals['calories'] ?? 0}/${_goals['calorieGoal'] ?? 2000} kcal'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_dailyTotals['calories'] ?? 0) /
                          (_goals['calorieGoal'] ?? 2000),
                    ),
                    const SizedBox(height: 16),
                    // Protein
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Protein'),
                        Text(
                            '${_dailyTotals['protein'] ?? 0}/${_goals['proteinGoal'] ?? 80} g'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_dailyTotals['protein'] ?? 0) /
                          (_goals['proteinGoal'] ?? 80),
                    ),
                    const SizedBox(height: 16),
                    // Carbs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Carbs'),
                        Text(
                            '${_dailyTotals['carbs'] ?? 0}/${_goals['carbsGoal'] ?? 250} g'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_dailyTotals['carbs'] ?? 0) /
                          (_goals['carbsGoal'] ?? 250),
                    ),
                    const SizedBox(height: 16),
                    // Fat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fat'),
                        Text(
                            '${_dailyTotals['fat'] ?? 0}/${_goals['fatGoal'] ?? 65} g'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_dailyTotals['fat'] ?? 0) /
                          (_goals['fatGoal'] ?? 65),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Meal List
            Text(
              'Today\'s Meals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return Dismissible(
                    key: Key(meal['id']),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      try {
                        await _dietService.deleteMeal(meal['id']);
                        setState(() {
                          _meals.removeAt(index);
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${meal['name']} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await _dietService.addMeal(meal);
                                  _loadData();
                                },
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting meal: $e')),
                          );
                        }
                        // Reload the data in case of error
                        _loadData();
                      }
                    },
                    child: ListTile(
                      leading:
                          Icon(_getMealTypeIcon(meal['mealType'] ?? 'other')),
                      title: Text(meal['name'] ?? 'Unknown Meal'),
                      subtitle: Text(
                        'Calories: ${meal['calories']} | P: ${meal['protein']}g | C: ${meal['carbs']}g | F: ${meal['fat']}g',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: PopupMenuButton(
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'add_meal',
            child: Row(
              children: [
                Icon(Icons.restaurant),
                SizedBox(width: 8),
                Text('Add Meal'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'update_goals',
            child: Row(
              children: [
                Icon(Icons.track_changes),
                SizedBox(width: 8),
                Text('Update Goals'),
              ],
            ),
          ),
        ],
        onSelected: (value) async {
          if (value == 'add_meal') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMealScreen()),
            );
            if (result != null) {
              print('Received meal in UserDiet: $result'); // Debug log
              try {
                await _dietService.addMeal(result);
                print('Successfully added meal to database'); // Debug log
                _loadData(); // Reload data after adding a meal
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${result['name']} to your meals'),
                    ),
                  );
                }
              } catch (e) {
                print('Error adding meal to database: $e'); // Debug log
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding meal: $e'),
                    ),
                  );
                }
              }
            }
          } else if (value == 'update_goals') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UpdateGoalsScreen()),
            );
            if (result == true) {
              _loadData(); // Reload data after updating goals
            }
          }
        },
      ),
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.local_dining;
      default:
        return Icons.fastfood;
    }
  }
}


