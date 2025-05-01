/// A Flutter widget for managing user subscription options (simple local handling).
/// 
/// This screen allows the user to view their current subscription plan and choose 
/// between two subscription plans: 'Free' and 'Premium'. The current plan is 
/// displayed at the top, and users can switch plans by tapping on one of the options.
/// A snack bar is shown when the plan is switched.
///
/// Attributes:
/// - _currentPlan: A string representing the current subscription plan. Defaults to 'Free'.
/// 
/// Methods:
/// - _selectPlan: A function that updates the user's subscription plan and displays a snack bar.
library;
import 'package:flutter/material.dart';

class UserSubscription extends StatefulWidget {
  const UserSubscription({super.key});

  @override
  State<UserSubscription> createState() => _UserSubscriptionState();
}

class _UserSubscriptionState extends State<UserSubscription> {
  // The current subscription plan of the user.
  String _currentPlan = 'Free';

  /// Updates the current subscription plan and displays a SnackBar with the change.
  ///
  /// This method is called when the user taps on a subscription plan. It updates
  /// the `_currentPlan` state to reflect the selected plan and shows a SnackBar
  /// to confirm the change.
  ///
  /// Arguments:
  /// - `plan`: A string representing the selected subscription plan ('Free' or 'Premium').
  ///
  /// Returns:
  /// - Void. This method updates the state and displays a SnackBar.
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
            // Display the current plan
            Text(
              'Current Plan: $_currentPlan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Available plans title
            Text(
              'Available Plans',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Free plan selection
            ListTile(
              title: const Text('Free Plan'),
              subtitle: const Text('Basic access to features'),
              trailing: _currentPlan == 'Free'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _selectPlan('Free'),
            ),
            // Premium plan selection
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
