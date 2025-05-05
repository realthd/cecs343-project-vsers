import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/user/UserWorkout.dart'; // The screen under test
// Because UserWorkout.dart directly uses Firebase and a custom persistor,
// we need fakes/mocks for them.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:vsers/components/globals.dart'; // Assuming WorkoutStatePersistor is here or similar import

// Import the generated mocks for this file
import 'user_workout_test.mocks.dart';

// Tell build_runner to generate mocks ONLY for non-Firebase services used.
// Firebase instances will be faked. Mock the persistor.
@GenerateMocks([WorkoutStatePersistor]) // Add other *services* if UserWorkout uses them
void main() {
  // Use fake Firebase instances and mock persistor
  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockWorkoutStatePersistor mockWorkoutStatePersistor;
  late MockUser mockUser;

  // Test user ID
  const String testUserId = 'workout_user_123';

  // --- Helper to Set Up Fake Firestore Data ---
  Future<void> setupFakeFirestoreWithPlan(String planId, Map<String, dynamic> planData, {bool assignToUser = true}) async {
    // Add the workout plan document
    await fakeFirestore.collection('workout_plans').doc(planId).set(planData);

    // Assign the plan to the user document if needed
    if (assignToUser) {
      await fakeFirestore.collection('users').doc(testUserId).set({
        'username': 'workoutuser',
        // This field name MUST match what UserWorkout reads
        'current_workout_plan': fakeFirestore.collection('workout_plans').doc(planId),
      });
    } else {
      await fakeFirestore.collection('users').doc(testUserId).set({
        'username': 'workoutuser',
        // No plan assigned
      });
    }
  }

  // Helper function to build the widget with fakes/mocks
  Widget createUserWorkoutScreenWithFakes({Map<String, dynamic>? initialPersistedState}) {
    // Configure the mock persistor *before* the widget uses it
    when(mockWorkoutStatePersistor.loadState()).thenReturn(initialPersistedState ?? {}); // Return initial state or empty map
    when(mockWorkoutStatePersistor.saveState(any)).thenReturn(null); // Mock saveState
    when(mockWorkoutStatePersistor.clearState()).thenReturn(null); // Mock clearState

    // Using Provider to inject the mock persistor and fake Firebase instances
    return MultiProvider(
      providers: [
        Provider<WorkoutStatePersistor>.value(value: mockWorkoutStatePersistor),
        Provider<FirebaseAuth>.value(value: mockFirebaseAuth),
        Provider<FirebaseFirestore>.value(value: fakeFirestore),
      ],
      child: MaterialApp(
        home: UserWorkout(), // UserWorkout should use Provider.of or .instance
      ),
    );
  }

  // setUp runs before each test
  setUp(() async {
    // --- Mock FirebaseAuth Setup ---
    mockUser = MockUser(uid: testUserId, email: 'workout@example.com');
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // --- Fake Firestore Setup ---
    fakeFirestore = FakeFirebaseFirestore();
    // Add basic user doc (can be overridden in tests needing specific plans)
    await fakeFirestore.collection('users').doc(testUserId).set({'username': 'workoutuser'});

    // --- Mock Persistor Setup ---
    mockWorkoutStatePersistor = MockWorkoutStatePersistor();
    // Default stubbing moved to createWidget helper to allow overriding initial state per test

  });

  // --- Test Cases: Display ---
  group('UserWorkout Display', () {
    testWidgets('Displays exercises when plan is loaded', (WidgetTester tester) async {
      // Arrange: Setup Firestore with a specific plan
      final planId = 'testPlan1';
      final planData = {
        'name': 'Strength Basics',
        'workouts': [
          // Assumes structure: list of maps, each map has 'day' and 'exercises' list
          // Assumes today is Day 1 for simplicity
          {'day': 1, 'exercises': [
            {'name': 'Bench Press', 'sets': 3, 'reps': '5-8'},
            {'name': 'Overhead Press', 'sets': 3, 'reps': '8-10'}
          ]},
          {'day': 2, 'exercises': [ /* ... data for day 2 ... */ ]},
        ]
      };
      await setupFakeFirestoreWithPlan(planId, planData);

      // Act: Pump the screen
      await tester.pumpWidget(createUserWorkoutScreenWithFakes());
      await tester.pumpAndSettle(); // Wait for plan loading

      // Assert: Check if exercises for Day 1 are displayed
      // Adjust finders based on how your UI displays workout info
      expect(find.text('Day 1 Workout'), findsOneWidget, reason: "Should display title for current day's workout.");
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.textContaining('3 sets x 5-8 reps'), findsOneWidget); // Check details format
      expect(find.text('Overhead Press'), findsOneWidget);
      expect(find.textContaining('3 sets x 8-10 reps'), findsOneWidget);

      // Check FAB is present and shows 'Start' icon
      expect(find.widgetWithIcon(FloatingActionButton, Icons.play_arrow), findsOneWidget, reason: "Start Workout FAB should be visible.");
    });

    testWidgets('Shows message when no plan is selected', (WidgetTester tester) async {
      // Arrange: Ensure user has no plan assigned in fake Firestore
      await fakeFirestore.collection('users').doc(testUserId).set({'username': 'workoutuser'}); // No plan ref

      // Act: Pump the screen
      await tester.pumpWidget(createUserWorkoutScreenWithFakes());
      await tester.pumpAndSettle(); // Wait for loading attempt

      // Assert: Check for message indicating no plan
      // IMPORTANT: Match this text exactly with your UI message
      expect(find.text('No workout plan selected'), findsOneWidget, reason: "Should show message when no plan is assigned.");
      expect(find.byType(FloatingActionButton), findsNothing, reason: "FAB should not be visible when there's no plan.");
      expect(find.text('Bench Press'), findsNothing); // No exercises shown
    });
  });


  // --- Test Cases: Activity ---
  group('UserWorkout Activity', () {
    setUp(() async {
      // Ensure a plan is loaded for activity tests
      final planId = 'activityPlan';
      final planData = { 'name': 'Activity Test Plan', 'workouts': [
        {'day': 1, 'exercises': [
          {'name': 'Squats', 'sets': 3, 'reps': '10'},
          {'name': 'Lunges', 'sets': 2, 'reps': '12 per side'}
        ]},
      ]};
      await setupFakeFirestoreWithPlan(planId, planData);
    });

    testWidgets('Starts workout, timer runs, shows finish FAB', (WidgetTester tester) async {
      // Arrange: Pump widget with plan loaded
      await tester.pumpWidget(createUserWorkoutScreenWithFakes());
      await tester.pumpAndSettle();

      // Find the initial Start FAB
      final startFab = find.widgetWithIcon(FloatingActionButton, Icons.play_arrow);
      expect(startFab, findsOneWidget);

      // Act: Tap start workout FAB
      await tester.tap(startFab);
      // Pump slightly to initiate state change, but not long enough for timer to tick significantly
      await tester.pump(Duration(milliseconds: 100));

      // Assert: Check for running timer display (might start at 00:00) and finish FAB
      expect(find.text('00:00'), findsOneWidget, reason: "Timer should display initially."); // Or 00:01 if pump was longer
      expect(find.widgetWithIcon(FloatingActionButton, Icons.check), findsOneWidget, reason: "Finish FAB (check icon) should appear.");
      expect(find.widgetWithIcon(FloatingActionButton, Icons.play_arrow), findsNothing, reason: "Start FAB should disappear.");

      // Act: Pump timer forward significantly
      await tester.pump(Duration(seconds: 5));

      // Assert: Check timer display has updated
      expect(find.text('00:05'), findsOneWidget, reason: "Timer should show elapsed time.");

      // Assert: Verify persistor saved the 'startTime'
      final capturedState = verify(mockWorkoutStatePersistor.saveState(captureAny)).captured.last as Map<String, dynamic>;
      expect(capturedState['startTime'], isNotNull);
      expect(capturedState['startTime'], isA<DateTime>());
    });

    testWidgets('Marks set as complete and state is persisted', (WidgetTester tester) async {
      // Arrange: Pump widget with plan loaded
      await tester.pumpWidget(createUserWorkoutScreenWithFakes());
      await tester.pumpAndSettle();

      // Act: Start the workout first
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.play_arrow));
      await tester.pump(Duration(milliseconds: 100)); // Allow state update

      // Act: Find the first checkbox for the first exercise ('Squats')
      // This finder assumes Checkbox is associated with 'Squats' text. May need adjustment.
      final checkboxFinder = find.descendant(
        of: find.widgetWithText(ExpansionTile, 'Squats'), // Assuming exercises are in ExpansionTiles
        matching: find.byType(Checkbox),
      ).first; // Get the first checkbox within the Squats tile

      // Verify initial state (unchecked)
      expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse, reason: "Checkbox should be initially unchecked.");

      // Act: Tap the checkbox
      await tester.tap(checkboxFinder);
      await tester.pump(); // Rebuild UI with checked box

      // Assert: Checkbox is now checked
      expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue, reason: "Checkbox should be checked after tapping.");

      // Assert: Verify persistor saved the updated set completion state
      // This assumes your state saving key looks something like 'completedSets_Squats_0'
      final capturedState = verify(mockWorkoutStatePersistor.saveState(captureAny)).captured.last as Map<String, dynamic>;
      expect(capturedState['completedSets_Squats_0'], isTrue, reason: "Persisted state should reflect the completed set.");
      // You might need to adjust the key ('completedSets_Squats_0') based on how you actually store it
    });
  });
}