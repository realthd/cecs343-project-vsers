import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/user/UserInsights.dart';
import 'package:vsers/firebase/DietService.dart';
import 'package:vsers/firebase/UserDb.dart'; // Assuming UserDatabaseService fetches activity
import 'package:fl_chart/fl_chart.dart'; // Needed for chart type checks
// Import FirebaseAuth if UserInsights directly uses FirebaseAuth.instance.currentUser
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'; // Use mock auth

// Import the generated mocks for this file
import 'user_insights_test.mocks.dart';

// Tell build_runner to generate mocks for services used by UserInsights
// NOTE: If UserInsights uses FirebaseAuth directly, we use firebase_auth_mocks instead
@GenerateMocks([DietService, UserDatabaseService])
void main() {
  // Declare mock variables
  late MockDietService mockDietService;
  late MockUserDatabaseService mockUserDbService;
  // Use MockFirebaseAuth for fake user authentication
  late MockFirebaseAuth mockFirebaseAuth;

  // Helper function to build the widget with injected mocks and fake auth
  Widget createInsightsScreenWithMocks() {
    // Using Provider for injection - adapt if needed
    return MultiProvider(
      providers: [
        // Provide the mock services
        Provider<DietService>.value(value: mockDietService),
        Provider<UserDatabaseService>.value(value: mockUserDbService),
        // Provide the mock FirebaseAuth instance
        Provider<FirebaseAuth>.value(value: mockFirebaseAuth),
      ],
      child: MaterialApp(
        home: UserInsights(),
      ),
    );
  }

  // setUp runs before each test
  setUp(() {
    // Create fresh mock instances
    mockDietService = MockDietService();
    mockUserDbService = MockUserDatabaseService();

    // --- Mock FirebaseAuth Setup ---
    // Create a mock user
    final mockUser = MockUser(
      uid: 'insights_user_123',
      email: 'insights@example.com',
    );
    // Initialize mock FirebaseAuth with the logged-in mock user
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // --- Default Stubbing ---
    // Stub service calls for the default view ('Past Week')
    // Stub getUserActivity (assuming it returns workout count/data for chart)
    when(mockUserDbService.getUserActivity(any, 'Past Week')) // Match user ID and range
        .thenAnswer((_) async => {'workoutsCompleted': 3, 'workoutsGoal': 5, /* ... chart data ... */});

    // Stub getDietData (assuming it returns calorie/macro data for chart/display)
    when(mockDietService.getDietData(any, 'Past Week')) // Match user ID and range
        .thenAnswer((_) async => {'avgCalories': 2100, 'avgProtein': 155, /* ... chart data ... */});

    // Stub calls for the 'Today' view
    when(mockUserDbService.getUserActivity(any, 'Today'))
        .thenAnswer((_) async => {'workoutsCompleted': 1, 'workoutsGoal': 1, /* ... */});
    when(mockDietService.getDietData(any, 'Today'))
        .thenAnswer((_) async => {'avgCalories': 1950, 'avgProtein': 140, /* ... */});
  });

  // --- Test Cases ---
  testWidgets('UserInsights - Displays default view (Past Week) correctly', (WidgetTester tester) async {
    // Arrange: Pump the screen with mocks injected
    await tester.pumpWidget(createInsightsScreenWithMocks());
    // Wait for async service calls to complete and UI to build
    await tester.pumpAndSettle();

    // Assert: Check for default elements based on stubbed 'Past Week' data
    expect(find.text('Activity Insights'), findsOneWidget, reason: "Screen title should be present.");
    // Check Dropdown has default value
    expect(find.widgetWithText(DropdownButton<String>, 'Past Week'), findsOneWidget, reason: "Dropdown should default to 'Past Week'.");

    // Check for chart (BarChart might be specific, check your implementation)
    // Use a more generic finder if the chart type changes based on data
    expect(find.byType(BarChart), findsOneWidget, reason: "A BarChart should be displayed for 'Past Week'.");

    // Check for text derived from stubbed data
    expect(find.textContaining('3 / 5 Workouts Completed'), findsOneWidget, reason: "Workout progress text should reflect stubbed data.");
    expect(find.textContaining('Avg Calories: 2100'), findsOneWidget, reason: "Average calories text should reflect stubbed data.");
    // Add more checks for protein, other stats, etc.
  });

  testWidgets('UserInsights - Changes view when dropdown selection changes', (WidgetTester tester) async {
    // Arrange: Pump the screen and wait for initial build ('Past Week')
    await tester.pumpWidget(createInsightsScreenWithMocks());
    await tester.pumpAndSettle();

    // Verify initial state (based on 'Past Week' stubs)
    expect(find.textContaining('3 / 5 Workouts Completed'), findsOneWidget);
    expect(find.textContaining('Avg Calories: 2100'), findsOneWidget);

    // Act: Tap the dropdown to open it
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle(); // Wait for dropdown menu animation

    // Act: Select 'Today' from the dropdown items
    // '.last' helps if 'Today' text appears elsewhere
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle(); // Wait for state update, new service calls, and rebuild

    // Assert: Check if view updated based on stubbed 'Today' data
    // Dropdown now shows 'Today'
    expect(find.widgetWithText(DropdownButton<String>, 'Today'), findsOneWidget, reason: "Dropdown should now show 'Today'.");

    // Check for updated text
    expect(find.textContaining('1 / 1 Workouts Completed'), findsOneWidget, reason: "Workout text should update for 'Today'.");
    expect(find.textContaining('Avg Calories: 1950'), findsOneWidget, reason: "Calorie text should update for 'Today'.");

    // Assert: Verify the correct service methods were called for 'Today'
    verify(mockUserDbService.getUserActivity(mockFirebaseAuth.currentUser!.uid, 'Today')).called(1);
    verify(mockDietService.getDietData(mockFirebaseAuth.currentUser!.uid, 'Today')).called(1);

    // Optionally, check if the chart type or specific data points changed if possible/necessary
  });
}