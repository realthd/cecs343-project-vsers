import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DietService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Get user's diet goals
  Future<Map<String, dynamic>> getDietGoals() async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc('goals')
        .get();

    return doc.data() ??
        {
          'calorieGoal': 2000,
          'proteinGoal': 80,
          'carbsGoal': 250,
          'fatGoal': 65,
        };
  }

  // Set user's diet goals
  Future<void> setDietGoals({
    required int calorieGoal,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc('goals')
        .set({
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
    });
  }

  // Add a meal for today
  Future<void> addMeal(Map<String, dynamic> meal) async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    print('Adding meal: $meal'); // Debug log
    print('Date string: $dateStr'); // Debug log
    print('User ID: $userId'); // Debug log

    // Add the meal
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc(dateStr)
        .collection('meals')
        .add({
      ...meal,
      'timestamp': Timestamp.now(),
    });

    print('Meal added with ID: ${docRef.id}'); // Debug log

    // Update daily totals
    await updateDailyTotals(dateStr);
  }

  // Get today's meals
  Future<List<Map<String, dynamic>>> getTodaysMeals() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc(dateStr)
        .collection('meals')
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  // Update daily totals
  Future<void> updateDailyTotals(String dateStr) async {
    final mealsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc(dateStr)
        .collection('meals')
        .get();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (var doc in mealsSnapshot.docs) {
      final meal = doc.data();
      totalCalories += meal['calories'] as int;
      totalProtein += meal['protein'] as int;
      totalCarbs += meal['carbs'] as int;
      totalFat += meal['fat'] as int;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc(dateStr)
        .set({
      'dailyTotals': {
        'calories': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
      }
    }, SetOptions(merge: true));
  }

  // Get daily totals
  Future<Map<String, dynamic>> getDailyTotals() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc(dateStr)
        .get();

    return (doc.data()?['dailyTotals'] as Map<String, dynamic>?) ??
        {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
        };
  }

  // Delete a meal
  Future<void> deleteMeal(String mealId) async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    print('Deleting meal with ID: $mealId'); // Debug log

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .doc(dateStr)
        .collection('meals')
        .doc(mealId)
        .delete();

    print('Meal deleted, updating daily totals'); // Debug log
    await updateDailyTotals(dateStr);
  }
}
