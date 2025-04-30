/// """User Insights Module
///
/// Provides a screen that displays insights into user fitness activity,
/// such as calories burned and workout consistency, over various time ranges.
/// Users can view this data through visualizations like progress bars and charts,
/// and toggle between daily, weekly, or monthly views for personalized tracking.
///
/// Usage:
///   Include this widget as a tab in the UserDashboard to give users access
///   to their activity trends and goals.
/// """
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// """Displays user insights over selectable time periods.
///
/// Attributes:
///   key (Key): Optional widget key to uniquely identify the widget.
/// """
class UserInsights extends StatefulWidget {
  const UserInsights({super.key});

  @override
  State<UserInsights> createState() => _UserInsightsState();
}

/// """Manages state and logic for the UserInsights screen.
///
/// Attributes:
///   selectedRange (String): Currently selected time period for the insights view.
///   ranges (List<String>): Available time period options for selection.
///   caloriesData (Map<String, List<double>>): Mock calorie data per time range.
///   workoutCompleted (Map<String, int>): Number of completed workouts by period.
///   workoutGoals (Map<String, int>): Target workouts for each period.
/// """
class _UserInsightsState extends State<UserInsights> {
  String selectedRange = 'Past Week';
  final List<String> ranges = ['Today', 'Past Week', 'Past Month'];

  final Map<String, List<double>> caloriesData = {
    'Today': [500],
    'Past Week': [400, 600, 500, 450, 700, 300, 550],
    'Past Month': List.generate(30, (index) => 300 + (index % 5) * 50),
  };

  final Map<String, int> workoutCompleted = {
    'Today': 1,
    'Past Week': 3,
    'Past Month': 18,
  };

  final Map<String, int> workoutGoals = {
    'Today': 1,
    'Past Week': 6,
    'Past Month': 24,
  };

  /// """Builds a bar chart visualization for the given data list.
  ///
  /// Args:
  ///   data (List<double>): The y-axis values for each bar in the chart.
  ///
  /// Returns:
  ///   Widget: A BarChart widget that displays the provided data.
  ///
  /// Raises:
  ///   None
  /// """
  Widget _buildBarChart(List<double> data) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                return Text(index < data.length ? '${index + 1}' : '');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .map((i, val) => MapEntry(
                  i,
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: val, color: Colors.blueAccent),
                  ]),
                ))
            .values
            .toList(),
      ),
    );
  }

  /// """Builds the user insights screen based on selected time period.
  ///
  /// Args:
  ///   context (BuildContext): The widget tree context.
  ///
  /// Returns:
  ///   Widget: A Scaffold that displays calories burned and workout consistency
  ///   data, with a dropdown for selecting the date range and a bar chart visualization.
  ///
  /// Raises:
  ///   None
  /// """
  @override
  Widget build(BuildContext context) {
    final calData = caloriesData[selectedRange]!;
    final completed = workoutCompleted[selectedRange]!;
    final goal = workoutGoals[selectedRange]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Dropdown to select time range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing: $selectedRange',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownButton<String>(
                  value: selectedRange,
                  items: ranges.map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newRange) {
                    if (newRange != null) {
                      setState(() => selectedRange = newRange);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Calories burned chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Calories Burned'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: _buildBarChart(calData),
                    ),
                    const SizedBox(height: 8),
                    Text('${calData.reduce((a, b) => a + b).toInt()} kcal total'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Workout consistency tracker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Workout Consistency'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: completed / goal),
                    const SizedBox(height: 8),
                    Text('$completed / $goal workouts completed'),
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
