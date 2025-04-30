import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A class representing a workout goal (kept for potential future use).
class WorkoutGoal {
  final String name;
  final String target;
  final DateTime deadline;

  WorkoutGoal({
    required this.name,
    required this.target,
    required this.deadline,
  });
}

class UserWorkout extends StatefulWidget {
  UserWorkout({Key? key}) : super(key: key);

  /// Notifier to control the FAB externally
  final ValueNotifier<Widget?> fabNotifier = ValueNotifier<Widget?>(null);

  @override
  State<UserWorkout> createState() => _UserWorkoutState();
}

class _UserWorkoutState extends State<UserWorkout> {
  bool _isWorkoutActive = false;
  int _currentDay = 1;
  Map<String, dynamic>? _currentPlan;
  List<Map<String, dynamic>> _dailyExercises = [];
  Map<String, List<bool>> _completedSets = {};
  int _timerSeconds = 0;
  Timer? _timer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentWorkoutPlan();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.fabNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentWorkoutPlan() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        widget.fabNotifier.value = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('current_workout_plan')) {
        throw Exception('No workout plan selected');
      }

      final planRef = userDoc.data()!['current_workout_plan'] as DocumentReference;
      final planDoc = await planRef.get();
      if (!planDoc.exists) throw Exception('Workout plan not found');

      setState(() {
        _currentPlan = planDoc.data() as Map<String, dynamic>;
        _updateDailyExercises();
        _isLoading = false;
        _updateFab();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading workout plan: $e';
        _isLoading = false;
        _updateFab();
      });
    }
  }

  void _updateDailyExercises() {
    if (_currentPlan == null) return;
    final workouts = _currentPlan!['workouts'] as List<dynamic>? ?? [];
    final workout = workouts.firstWhere(
          (w) => w['day'] == _currentDay,
      orElse: () => {'exercises': []},
    );
    _dailyExercises = List<Map<String, dynamic>>.from(workout['exercises'] ?? []);
    _completedSets = {
      for (var ex in _dailyExercises)
        ex['name']: List<bool>.filled(ex['sets'] as int, false),
    };
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _timerSeconds = 0;
      widget.fabNotifier.value = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _timerSeconds++);
    });
  }

  void _markSetCompleted(String name, int idx) {
    setState(() {
      _completedSets[name]![idx] = true;
    });
  }

  bool _isExerciseCompleted(String name) {
    return _completedSets[name]?.every((c) => c) ?? false;
  }

  Future<void> _stopWorkout() async {
    _timer?.cancel();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final record = {
        'plan_id': _currentPlan!['name'],
        'day': _currentDay,
        'date': Timestamp.now(),
        'duration_seconds': _timerSeconds,
        'exercises': _dailyExercises.map((ex) {
          final name = ex['name'];
          return {
            'name': name,
            'sets': ex['sets'],
            'reps': ex['reps'],
            'completed_sets': _completedSets[name]!
                .asMap()
                .entries
                .where((e) => e.value)
                .map((e) => e.key + 1)
                .toList(),
          };
        }).toList(),
      };

      final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(stamp)
          .set(record);

      setState(() {
        _currentDay = (_currentDay % (_currentPlan!['duration'] as int)) + 1;
        _isWorkoutActive = false;
        _timerSeconds = 0;
        _updateDailyExercises();
        _updateFab();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving workout: $e';
        _updateFab();
      });
    }
  }

  void _updateFab() {
    if (_isWorkoutActive || _isLoading || _errorMessage != null) {
      widget.fabNotifier.value = null;
    } else {
      widget.fabNotifier.value = FloatingActionButton(
        onPressed: _startWorkout,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.play_arrow, color: Colors.white),
        tooltip: 'Start Workout',
      );
    }
  }

  String _formatTimer(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: ValueListenableBuilder<Widget?>(
        valueListenable: widget.fabNotifier,
        builder: (_, fab, __) => fab ?? const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isWorkoutActive)
              Card(
                color: theme.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Center(
                    child: Text(
                      'Workout Time: ${_formatTimer(_timerSeconds)}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Day $_currentDay Workout',
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dailyExercises.length,
                itemBuilder: (context, idx) {
                  final ex = _dailyExercises[idx];
                  final name = ex['name'] as String;
                  final sets = ex['sets'] as int;
                  final reps = ex['reps'] as int;
                  final done = _isExerciseCompleted(name);
                  return Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: done ? theme.colorScheme.secondaryContainer : theme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (done)
                                Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 28),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$sets sets of $reps reps',
                            style: theme.textTheme.bodySmall,
                          ),
                          if (_isWorkoutActive && !done) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: List.generate(sets, (i) {
                                final sel = _completedSets[name]![i];
                                return ChoiceChip(
                                  label: Text('${i + 1}'),
                                  selected: sel,
                                  onSelected: (_) => _markSetCompleted(name, i),
                                  selectedColor: theme.colorScheme.primaryContainer,
                                  backgroundColor: theme.colorScheme.surfaceVariant,
                                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                    color: sel
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isWorkoutActive)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _stopWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Stop Workout',
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onError),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

