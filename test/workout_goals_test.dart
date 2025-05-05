import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/components/workoutGoals.dart';
// Because workoutGoals.dart directly uses Firebase, we need fakes/mocks for them
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// Import destination page for navigation check
import 'package:vsers/user/UserHomepage.dart'; // Example destination

// NOTE: It's highly recommended to refactor WorkoutGoalsPage to use a
// dedicated service (e.g., WorkoutGoalService) instead of directly calling
// FirebaseAuth.instance and FirebaseFirestore.instance. Then you could mock
// that service instead of using fake Firebase instances.

void main() {
  // Use fake Firebase instances for testing direct Firebase calls
  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore fakeFirestore;

  // Helper function to build the widget with fake Firebase instances
  Widget createWorkoutGoalsScreenWithFakes() {
    // Using Provider to make fake instances accessible if needed,
    // but WorkoutGoalsPage likely calls .instance directly.
    // The main purpose here is to initialize the fakes.
    return MaterialApp(
      home: WorkoutGoalsPage(), // This widget will use the fake instances automatically
      routes: {
        '/userHome': (context) => Scaffold(body: Center(child: Text('Mock User Home Page'))),
      },
    );
  }

  // setUp runs before each test
  setUp(() {
    // Create a mock user
    final mockUser = MockUser(
      uid: 'goal_user_123',
      email: 'goal@example.com',
    );
    // Initialize mock FirebaseAuth with the logged-in mock user
    // NOTE: WorkoutGoalsPage uses FirebaseAuth.instance, so this mock needs
    // to be setup globally IF POSSIBLE, or the widget refactored.
    // For simplicity here, we assume the test environment can handle instance calls,
    // but ideally the widget should take FirebaseAuth as a dependency.
    // If direct instance calls fail, refactoring is the best solution.
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Initialize fake Firestore
    fakeFirestore = FakeFirebaseFirestore();
  });

  // --- Test Cases ---
  testWidgets('WorkoutGoals - Selecting options enables Next/Finish buttons', (WidgetTester tester) async {
    // Arrange: Pump the screen
    // Provide the fake instances if WorkoutGoalsPage expects them via Provider
    // await tester.pumpWidget(
    //   Provider<FirebaseAuth>.value(
    //     value: mockFirebaseAuth,
    //     child: Provider<FirebaseFirestore>.value( // Less common, usually .instance is used
    //       value: fakeFirestore,
    //       child: createWorkoutGoalsScreenWithFakes(),
    //     ),
    //   )
    // );
    // If it uses .instance, just pumping might work if fakes are set up globally for tests.
    await tester.pumpWidget(createWorkoutGoalsScreenWithFakes());


    // Page 1: Goal Type
    final nextButton1Finder = find.widgetWithText(ElevatedButton, 'Next');
    expect(tester.widget<ElevatedButton>(nextButton1Finder).enabled, isFalse, reason: "Next button should be disabled initially on page 1.");
    await tester.tap(find.text('Strength Training')); // Select an option
    await tester.pump(); // Rebuild UI
    expect(tester.widget<ElevatedButton>(nextButton1Finder).enabled, isTrue, reason: "Next button should be enabled after selection on page 1.");
    await tester.tap(nextButton1Finder);
    await tester.pumpAndSettle(); // Animate to next page

    // Page 2: Days per Week
    final nextButton2Finder = find.widgetWithText(ElevatedButton, 'Next');
    expect(tester.widget<ElevatedButton>(nextButton2Finder).enabled, isFalse, reason: "Next button should be disabled initially on page 2.");
    await tester.tap(find.text('3 days')); // Select an option
    await tester.pump(); // Rebuild UI
    expect(tester.widget<ElevatedButton>(nextButton2Finder).enabled, isTrue, reason: "Next button should be enabled after selection on page 2.");
    await tester.tap(nextButton2Finder);
    await tester.pumpAndSettle(); // Animate to next page

    // Page 3: Duration
    final finishButtonFinder = find.widgetWithText(ElevatedButton, 'Finish');
    expect(tester.widget<ElevatedButton>(finishButtonFinder).enabled, isFalse, reason: "Finish button should be disabled initially on page 3.");
    await tester.tap(find.text('60 minutes')); // Select an option
    await tester.pump(); // Rebuild UI
    expect(tester.widget<ElevatedButton>(finishButtonFinder).enabled, isTrue, reason: "Finish button should be enabled after selection on page 3.");
  });

  testWidgets('WorkoutGoals - Saves goals to Firestore and navigates on Finish', (WidgetTester tester) async {
    // Arrange: Pump the screen (provide fakes if needed)
    // await tester.pumpWidget(
    //   Provider<FirebaseAuth>.value(...) // As above
    // );
    await tester.pumpWidget(createWorkoutGoalsScreenWithFakes());

    // Act: Navigate through pages and select options
    await tester.tap(find.text('Hypertrophy (Muscle Building)'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('5 days'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('90 minutes'));
    await tester.pump();

    // Act: Tap Finish button
    final finishButton = find.widgetWithText(ElevatedButton, 'Finish');
    await tester.tap(finishButton);
    await tester.pumpAndSettle(); // Allow time for Firestore write and navigation

    // Assert: Verify data was saved to Fake Firestore
    final userDoc = await fakeFirestore.collection('users').doc(mockFirebaseAuth.currentUser!.uid).get();
    expect(userDoc.exists, isTrue, reason: "User document should exist in fake Firestore.");
    final data = userDoc.data();
    expect(data, isNotNull);
    // Match the expected values based on selections
    expect(data!['workoutGoal'], 'hypertrophy', reason: "Saved goal should match selection.");
    expect(data['workoutDays'], 5, reason: "Saved days should match selection.");
    expect(data['workoutDuration'], 90, reason: "Saved duration should match selection.");
    // Add checks for other fields if WorkoutGoalsPage saves them

    // Assert: Verify navigation occurred
    expect(find.text('Mock User Home Page'), findsOneWidget, reason: "Should navigate to User Home page after finishing goals.");
    expect(find.byType(WorkoutGoalsPage), findsNothing, reason: "WorkoutGoals page should be removed after navigation.");
  });
}