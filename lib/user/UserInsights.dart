import 'package:flutter/material.dart';

/// Displays user fitness and nutrition insights such as
/// weekly progress, calories burned, and workout consistency.
class UserInsights extends StatelessWidget {
  const UserInsights({super.key});

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
