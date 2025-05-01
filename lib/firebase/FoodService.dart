import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all preset food items
  Future<List<Map<String, dynamic>>> getPresetFoods() async {
    final snapshot = await _firestore.collection('foods').orderBy('name').get();
    final foods = snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();

    // If the foods collection is empty, populate it with sample data
    if (foods.isEmpty) {
      print('Foods collection is empty, populating with sample data...');
      await populateSampleFoods();
      // Get the foods again after populating
      final newSnapshot =
          await _firestore.collection('foods').orderBy('name').get();
      return newSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    }

    return foods;
  }

  // Populate the database with sample foods if it's empty
  Future<void> populateSampleFoods() async {
    try {
      final batch = _firestore.batch();

      for (var food in sampleFoods) {
        final docRef = _firestore.collection('foods').doc();
        // Add isUserCreated: false to distinguish from user-created meals
        batch.set(docRef, {
          ...food,
          'isUserCreated': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print(
          'Successfully populated database with ${sampleFoods.length} sample foods');
    } catch (e) {
      print('Error populating sample foods: $e');
      rethrow;
    }
  }

  // Force repopulate sample foods
  Future<void> forceRepopulateSampleFoods() async {
    try {
      // Delete all existing non-user-created foods
      final snapshot = await _firestore
          .collection('foods')
          .where('isUserCreated', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Add sample foods
      await populateSampleFoods();
    } catch (e) {
      print('Error repopulating sample foods: $e');
      rethrow;
    }
  }

  // Add a new preset food item (admin only)
  Future<void> addPresetFood(Map<String, dynamic> food) async {
    await _firestore.collection('foods').add(food);
  }

  // Add a user-created meal to the foods collection
  Future<void> addUserCreatedMeal(Map<String, dynamic> meal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get the user's name from their profile
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final creatorName =
        '${userData['firstname'] ?? ''} ${userData['lastname'] ?? ''}'.trim();

    // Add creator information to the meal
    final enrichedMeal = {
      ...meal,
      'isUserCreated': true,
      'createdBy': creatorName,
      'creatorId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    print('Adding user-created meal: $enrichedMeal');
    await _firestore.collection('foods').add(enrichedMeal);
  }

  // Add multiple preset foods at once (admin only)
  Future<void> addMultiplePresetFoods(List<Map<String, dynamic>> foods) async {
    final batch = _firestore.batch();

    for (var food in foods) {
      final docRef = _firestore.collection('foods').doc();
      batch.set(docRef, food);
    }

    await batch.commit();
  }

  // Sample food data to populate the database
  static List<Map<String, dynamic>> sampleFoods = [
    {
      'name': 'Oatmeal with Banana',
      'calories': 280,
      'protein': 8,
      'carbs': 45,
      'fat': 6,
      'mealType': 'breakfast',
    },
    {
      'name': 'Scrambled Eggs',
      'calories': 220,
      'protein': 14,
      'carbs': 2,
      'fat': 16,
      'mealType': 'breakfast',
    },
    {
      'name': 'Greek Yogurt with Berries',
      'calories': 150,
      'protein': 15,
      'carbs': 12,
      'fat': 4,
      'mealType': 'breakfast',
    },
    {
      'name': 'Chicken Salad',
      'calories': 350,
      'protein': 25,
      'carbs': 10,
      'fat': 12,
      'mealType': 'lunch',
    },
    {
      'name': 'Turkey Sandwich',
      'calories': 420,
      'protein': 28,
      'carbs': 35,
      'fat': 15,
      'mealType': 'lunch',
    },
    {
      'name': 'Tuna Wrap',
      'calories': 380,
      'protein': 24,
      'carbs': 30,
      'fat': 14,
      'mealType': 'lunch',
    },
    {
      'name': 'Grilled Chicken Breast',
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fat': 3,
      'mealType': 'dinner',
    },
    {
      'name': 'Salmon Fillet',
      'calories': 280,
      'protein': 28,
      'carbs': 0,
      'fat': 18,
      'mealType': 'dinner',
    },
    {
      'name': 'Vegetable Stir Fry',
      'calories': 250,
      'protein': 12,
      'carbs': 25,
      'fat': 8,
      'mealType': 'dinner',
    },
    {
      'name': 'Apple with Peanut Butter',
      'calories': 200,
      'protein': 7,
      'carbs': 25,
      'fat': 8,
      'mealType': 'snack',
    },
    {
      'name': 'Protein Bar',
      'calories': 220,
      'protein': 20,
      'carbs': 25,
      'fat': 5,
      'mealType': 'snack',
    },
    {
      'name': 'Mixed Nuts',
      'calories': 180,
      'protein': 6,
      'carbs': 6,
      'fat': 16,
      'mealType': 'snack',
    },
  ];
}

