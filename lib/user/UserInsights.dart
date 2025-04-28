/// A Flutter widget module that presents user fitness and nutrition insights, 
/// including weekly summaries, calories burned, and workout consistency.
/// 
import 'package:flutter/material.dart';

/// A stateless widget that shows weekly fitness insights for the user.
/// 
/// Attributes:
/// - key: An optional unique identifier for the widget.
class UserInsights extends StatelessWidget {
  const UserInsights({super.key});
  /// Builds the UI for the UserInsights screen.
  /// 
  /// Args:
  /// - context (BuildContext): The context in which the widget is built.
  /// 
  /// Returns:
  /// - Widget: A Scaffold containing weekly summary and progress information.
  /// 
  /// Summary:
  /// Constructs the insights layout, showing calories burned, workout consistency, 
  /// and returns the assembled Scaffold widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Displays the weekly summary section.
            Text(
              'Weekly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            /// Card showing calories burned progress.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Calories Burned'),
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(value: 0.75),
                    const SizedBox(height: 8),
                    Text('3,500 kcal / 4,500 kcal target'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Card showing workout consistency progress.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Workout Consistency'),
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(value: 0.5),
                    const SizedBox(height: 8),
                    Text('3 / 6 workouts completed'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
