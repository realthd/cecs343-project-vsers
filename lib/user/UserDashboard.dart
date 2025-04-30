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

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  final _userWorkoutKey = GlobalKey<UserWorkoutState>();

  /// Handles the tap event of a bottom navigation item.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  // List of widgets for each tab
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
    _widgetOptions = <Widget>[
      const KeepAliveWrapper(child: UserHomepage()),
      KeepAliveWrapper(child: UserWorkout(key: _userWorkoutKey)),
      const KeepAliveWrapper(child: UserDiet()),
      const KeepAliveWrapper(child: UserInsights()),
      const KeepAliveWrapper(child: UserSettings()),
    ];
    debugPrint('UserDashboard: initState called');
  }

  @override
  void dispose() {
    _tabController.dispose();
    debugPrint('UserDashboard: dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: _widgetOptions,
      ),
      floatingActionButton: _selectedIndex == 1
          ? ValueListenableBuilder<Widget?>(
        valueListenable:
        _userWorkoutKey.currentState?.fabNotifier ??
            ValueNotifier(null),
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

/// Wrapper to ensure each tab's widget is kept alive
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}