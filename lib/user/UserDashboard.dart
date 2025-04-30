import 'package:flutter/material.dart';
import 'package:vsers/user/UserSettings.dart';
import 'package:vsers/user/UserWorkout.dart';
import 'userHomepage.dart';
import 'userDiet.dart';
import 'userInsights.dart';

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
  int _selectedIndex = 0;
  final _userWorkout = UserWorkout();

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

  static List<Widget> _widgetOptions = <Widget>[
    UserHomepage(),
    UserWorkout(),
    UserDiet(),
    UserInsights(),
    UserSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 1
          ? ValueListenableBuilder<Widget?>(
        valueListenable: _userWorkout.fabNotifier,
        builder: (context, fab, child) => fab ?? const SizedBox.shrink(),
      )
          : null,
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
            icon: Icon(Icons.restaurant_menu),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}