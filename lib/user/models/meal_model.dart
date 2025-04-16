import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class representing a meal with its nutritional information.
class Meal {
  /// Unique identifier for the meal
  final String id;

  /// Name of the meal
  final String name;

  /// Total calories in the meal
  final int calories;

  /// Protein content in grams
  final double protein;

  /// Carb content in grams
  final double carbs;

  /// Fat content in grams
  final double fat;

  /// Datetime for consumption
  final DateTime dateTime;

  /// Type of meal (breakfast, lunch, dinner, snack)
  final String mealType;

  /// Optional notes about the meal
  final String? notes;

  /// possible image for food?
  /// final String? imageUrl;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dateTime,
    required this.mealType,
    this.notes,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: map['calories'] as int,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      mealType: map['mealType'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'dateTime': dateTime,
      'mealType': mealType,
      'notes': notes,
    };
  }
}
