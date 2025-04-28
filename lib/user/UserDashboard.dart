import 'package:flutter/material.dart';
import 'userHomepage.dart';
import 'userDiet.dart';
import 'userInsights.dart';
// Import userSubscriptions if it needs its own tab:
// import 'userSubscriptions.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0; // Index for the currently selected tab

  // List of widgets to display in the body based on the selected index
  static const List<Widget> _widgetOptions = <Widget>[
    UserHomepage(), // Index 0
    UserWorkout(),  // Index 1
    UserDiet(),     // Index 2
    UserInsights(), // Index 3
    UserSettings(), // Index 4 - Settings often makes sense here or in AppBar/Drawer
    // Add UserSubscriptions() here if it's a main tab
  ];

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