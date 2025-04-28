/// A Flutter widget for managing user subscription options (simple local handling).
/// 
/// Allows viewing current subscription and selecting Free or Premium plan.

import 'package:flutter/material.dart';

class UserSubscription extends StatefulWidget {
  const UserSubscription({super.key});

  @override
  State<UserSubscription> createState() => _UserSubscriptionState();
}

class _UserSubscriptionState extends State<UserSubscription> {
  String _currentPlan = 'Free';

  void _selectPlan(String plan) {
    setState(() {
      _currentPlan = plan;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to $plan plan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan: $_currentPlan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Available Plans',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Free Plan'),
              subtitle: const Text('Basic access to features'),
              trailing: _currentPlan == 'Free'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _selectPlan('Free'),
            ),
            ListTile(
              title: const Text('Premium Plan'),
              subtitle: const Text('Full access to all features'),
              trailing: _currentPlan == 'Premium'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _selectPlan('Premium'),
            ),
          ],
        ),
      ),
    );
  }
}
