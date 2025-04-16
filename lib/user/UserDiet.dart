import 'package:flutter/material.dart';

class UserDiet extends StatelessWidget {
  const UserDiet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card
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
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calorie placeholder'),
                        Text('60%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(value: 0.6),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Macronutrients Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Macronutrients',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Protein'),
                            Text('example grams'),
                            Text('example percentage'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Carbs'),
                            Text('example carbs'),
                            Text('example percentage'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Fat'),
                            Text('example fat'),
                            Text('example percentage'),
                          ],
                        ),
                      ],
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
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.free_breakfast),
                    title: Text('Breakfast'),
                    subtitle: Text('example food'),
                  ),
                  ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text('Lunch'),
                    subtitle: Text('example food'),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_dining),
                    title: Text('Dinner'),
                    subtitle: Text('example food'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
