import 'package:flutter/material.dart';
import '../firebase/FoodService.dart';

/// This screen allows users to add a meal, either by selecting from a list
/// of preset foods or by creating a custom meal. It supports filtering meals
/// by type (e.g., breakfast, lunch, dinner) and includes form validation.
class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  String _selectedMealType = 'breakfast';
  String _selectedFilter = 'all';
  final FoodService _foodService = FoodService();
  List<Map<String, dynamic>> _presetFoods = [];
  bool _isLoading = true;

  /// Loads the preset foods from the database. If loading fails, sample foods
  /// are used as a fallback.
  Future<void> _loadPresetFoods() async {
    try {
      final foods = await _foodService.getPresetFoods();
      setState(() {
        _presetFoods = foods;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading preset foods: $e');
      // If there's an error loading from Firebase, use the sample data
      setState(() {
        _presetFoods = FoodService.sampleFoods;
        _isLoading = false;
      });
    }
  }

  /// Filters the preset foods based on the selected filter.
  ///
  /// Returns a list of foods that match the selected filter. If 'all' is
  /// selected, all foods are returned.
  ///
  /// Args:
  ///   None.
  ///
  /// Returns:
  ///   List<Map<String, dynamic>>: List of foods that match the filter.
  List<Map<String, dynamic>> _getFilteredFoods() {
    if (_selectedFilter == 'all') {
      return _presetFoods;
    }
    return _presetFoods
        .where((food) => food['mealType'] == _selectedFilter)
        .toList();
  }

  /// Returns an appropriate icon based on the given meal type.
  ///
  /// Args:
  ///   mealType (String): The type of meal (e.g., 'breakfast', 'lunch').
  ///
  /// Returns:
  ///   IconData: The corresponding icon for the meal type.
  IconData _getMealTypeIcon(String mealType) {
    print('Getting icon for meal type: $mealType'); // Debug log
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.local_dining;
      case 'snack':
        return Icons.fastfood;
      default:
        print('Unknown meal type: $mealType'); // Debug log
        return Icons.fastfood;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  /// Displays a dialog for the user to add a custom meal.
  ///
  /// This dialog includes a form with fields for meal name, type, calories,
  /// protein, carbs, and fat. If the form is valid, the custom meal is added
  /// to the database.
  void _showCustomMealForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Meal'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Meal Name'),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter a meal name'
                      : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMealType,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                  items: [
                    DropdownMenuItem(
                      value: 'breakfast',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.free_breakfast),
                          const SizedBox(width: 8),
                          const Text('Breakfast'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'lunch',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant),
                          const SizedBox(width: 8),
                          const Text('Lunch'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dinner',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_dining),
                          const SizedBox(width: 8),
                          const Text('Dinner'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'snack',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fastfood),
                          const SizedBox(width: 8),
                          const Text('Snack'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMealType = value ?? 'breakfast';
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter calories' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _proteinController,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter protein' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter carbs' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fatController,
                  decoration: const InputDecoration(labelText: 'Fat (g)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter fat' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final meal = {
                  'name': _nameController.text,
                  'calories': int.parse(_caloriesController.text),
                  'protein': int.parse(_proteinController.text),
                  'carbs': int.parse(_carbsController.text),
                  'fat': int.parse(_fatController.text),
                  'mealType': _selectedMealType,
                };

                try {
                  // Add to shared food database
                  await _foodService.addUserCreatedMeal(meal);
                  print('Successfully added custom meal to shared database');

                  // Close the dialog and return to UserDiet with the meal data
                  Navigator.pop(context);
                  Navigator.pop(context, meal);

                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meal added to shared database'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error adding custom meal: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding meal: $e'),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime object into a user-friendly string.
  ///
  /// Given a DateTime object, this function returns a string representing the
  /// time elapsed since the given date in a human-readable format, such as
  /// 'today', 'yesterday', or 'X days ago'.
  ///
  /// Args:
  ///   date (DateTime): The date to format.
  ///
  /// Returns:
  ///   String: A string representing the formatted date.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFoods = _getFilteredFoods();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
        actions: [
          // Temporary button to repopulate sample foods
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                await _foodService.forceRepopulateSampleFoods();
                _loadPresetFoods(); // Reload the foods list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sample foods repopulated successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error repopulating foods: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal Type Filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'all');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.free_breakfast,
                            size: 16,
                            color: _selectedFilter == 'breakfast'
                                ? Colors.white
                                : null),
                        const SizedBox(width: 4),
                        const Text('Breakfast'),
                      ],
                    ),
                    selected: _selectedFilter == 'breakfast',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'breakfast');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant,
                            size: 16,
                            color: _selectedFilter == 'lunch'
                                ? Colors.white
                                : null),
                        const SizedBox(width: 4),
                        const Text('Lunch'),
                      ],
                    ),
                    selected: _selectedFilter == 'lunch',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'lunch');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_dining,
                            size: 16,
                            color: _selectedFilter == 'dinner'
                                ? Colors.white
                                : null),
                        const SizedBox(width: 4),
                        const Text('Dinner'),
                      ],
                    ),
                    selected: _selectedFilter == 'dinner',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'dinner');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fastfood,
                            size: 16,
                            color: _selectedFilter == 'snack'
                                ? Colors.white
                                : null),
                        const SizedBox(width: 4),
                        const Text('Snack'),
                      ],
                    ),
                    selected: _selectedFilter == 'snack',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'snack');
                    },
                  ),
                ],
              ),
            ),
          ),
          // Preset Meals Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final meal = filteredFoods[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            _getMealTypeIcon(meal['mealType']),
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(meal['name']),
                              ),
                              if (meal['isUserCreated'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'by ${meal['createdBy']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calories: ${meal['calories']} | P: ${meal['protein']}g | C: ${meal['carbs']}g | F: ${meal['fat']}g',
                              ),
                              if (meal['isUserCreated'] == true &&
                                  meal['createdAt'] != null)
                                Text(
                                  'Added ${_formatDate(meal['createdAt'].toDate())}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context, meal);
                          },
                        ),
                      );
                    },
                  ),
          ),
          // Add Custom Meal Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showCustomMealForm,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Custom Meal'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
