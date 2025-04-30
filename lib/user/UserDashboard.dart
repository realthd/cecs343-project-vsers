import 'package:flutter/material.dart';
import 'package:vsers/user/UserWorkout.dart';
import 'userHomepage.dart';
import 'userDiet.dart';
import 'userInsights.dart';
// Import userSubscriptions if it needs its own tab:
// import 'userSubscriptions.dart';

/// User Dashboard screen that contains tabs for various user features.
///
/// This screen provides a dashboard with different sections for the user to access 
/// their homepage, workout routines, diet plans, insights, and settings. It uses 
/// a bottom navigation bar to switch between these tabs. The tabs include:
/// - Home
/// - Workout
/// - Diet
/// - Insights
/// - Settings
/// 
/// Attributes:
/// - _selectedIndex: The index of the currently selected tab in the bottom navigation bar.
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0; // Index for the currently selected tab

  /// List of widgets corresponding to each tab in the bottom navigation bar.
  ///
  /// This list holds the widgets that represent different sections of the app, such as:
  /// - Home (UserHomepage)
  /// - Workout (UserWorkout)
  /// - Diet (UserDiet)
  /// - Insights (UserInsights)
  /// - Settings (UserWorkout, placeholder for settings screen)
  /// 
  /// You can add more widgets to this list as necessary (e.g., UserSubscriptions).
  static const List<Widget> _widgetOptions = <Widget>[
    UserHomepage(), // Index 0 - Home
    UserWorkout(),  // Index 1 - Workout
    UserDiet(),     // Index 2 - Diet
    UserInsights(), // Index 3 - Insights
    UserWorkout(),  // Index 4 - Settings (or another screen like UserSubscriptions)
    // Add UserSubscriptions() here if it's a main tab
  ];

  /// Handles the tap event of a bottom navigation item.
  /// 
  /// This function updates the `_selectedIndex` state to reflect the selected tab, 
  /// which in turn updates the displayed widget in the body of the screen.
  ///
  /// Arguments:
  /// - `index`: The index of the tapped navigation item.
  ///
  /// Returns:
  /// - Void. This function updates the state to reflect the new selected tab.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar might be added here or within individual screens
      // appBar: AppBar(title: const Text('User Dashboard')), // Example AppBar
      body: Center(
        // Display the widget from _widgetOptions based on the selected index
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), // Or Icons.food_bank
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Or Icons.insights
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          // Add UserSubscriptions item if needed:
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.subscriptions),
          //   label: 'Subs',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent, // Color for selected tab
        unselectedItemColor: Colors.grey, // Color for unselected tabs
        showUnselectedLabels: true, // Keep labels visible
        onTap: _onItemTapped, // Function called when a tab is tapped
        type: BottomNavigationBarType.fixed, // Use fixed if more than 3 items often
      ),
    );
  }
}
