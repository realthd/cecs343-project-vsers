import 'package:flutter/material.dart';
import '../firebase/DietService.dart';

/// Screen to update daily nutrition goals for the user.
///
/// This screen allows users to modify their daily goals for calories, protein, carbs, and fat. 
/// The data is loaded from and saved to the backend via the `DietService`.
/// 
/// Attributes:
/// - _formKey: A global key for the form state.
/// - _caloriesController: Controller for the calories input field.
/// - _proteinController: Controller for the protein input field.
/// - _carbsController: Controller for the carbs input field.
/// - _fatController: Controller for the fat input field.
/// - _dietService: Service to interact with diet-related data.
/// - _isLoading: Flag indicating whether the data is loading.
/// - _currentGoals: Holds the current goals data retrieved from the backend.
class UpdateGoalsScreen extends StatefulWidget {
  const UpdateGoalsScreen({super.key});

  @override
  State<UpdateGoalsScreen> createState() => _UpdateGoalsScreenState();
}

class _UpdateGoalsScreenState extends State<UpdateGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final DietService _dietService = DietService();
  bool _isLoading = true;
  Map<String, dynamic> _currentGoals = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
  }

  /// Loads the current diet goals from the backend.
  /// 
  /// Retrieves the current diet goals (calories, protein, carbs, and fat) from the backend 
  /// using the `DietService` and populates the corresponding text controllers.
  ///
  /// Exceptions:
  /// - Shows an error message if the goals cannot be loaded from the backend.
  Future<void> _loadCurrentGoals() async {
    try {
      final goals = await _dietService.getDietGoals();
      setState(() {
        _currentGoals = goals;
        _caloriesController.text = goals['calorieGoal'].toString();
        _proteinController.text = goals['proteinGoal'].toString();
        _carbsController.text = goals['carbsGoal'].toString();
        _fatController.text = goals['fatGoal'].toString();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading goals: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading goals: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  /// Saves the updated goals to the backend.
  /// 
  /// Validates the input fields, then saves the updated goals (calories, protein, carbs, and fat) 
  /// using the `DietService`. On successful save, navigates back to the previous screen 
  /// and shows a success message.
  ///
  /// Arguments:
  /// - None
  ///
  /// Returns:
  /// - Void. Navigates back and shows a success message upon success, or an error message upon failure.
  ///
  /// Exceptions:
  /// - Shows an error message if there was an issue saving the goals.
  Future<void> _saveGoals() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _dietService.setDietGoals(
          calorieGoal: int.parse(_caloriesController.text),
          proteinGoal: int.parse(_proteinController.text),
          carbsGoal: int.parse(_carbsController.text),
          fatGoal: int.parse(_fatController.text),
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goals updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating goals: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Goals'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Nutrition Goals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    // Calories
                    TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal)',
                        helperText: 'Recommended: 2000-2500 kcal',
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter calories';
                        }
                        final number = int.tryParse(value!);
                        if (number == null || number <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Protein
                    TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                        helperText: 'Recommended: 0.8-1g per kg of body weight',
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter protein';
                        }
                        final number = int.tryParse(value!);
                        if (number == null || number <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Carbs
                    TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(
                        labelText: 'Carbs (g)',
                        helperText: 'Recommended: 45-65% of total calories',
                        prefixIcon: Icon(Icons.grain),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter carbs';
                        }
                        final number = int.tryParse(value!);
                        if (number == null || number <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Fat
                    TextFormField(
                      controller: _fatController,
                      decoration: const InputDecoration(
                        labelText: 'Fat (g)',
                        helperText: 'Recommended: 20-35% of total calories',
                        prefixIcon: Icon(Icons.water_drop),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter fat';
                        }
                        final number = int.tryParse(value!);
                        if (number == null || number <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveGoals,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Save Goals'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
