import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/user/UpdateGoalsScreen.dart';
import 'package:vsers/firebase/DietService.dart'; // Real Diet service

// Import the generated mocks for this file
import 'update_goals_screen_test.mocks.dart';

// Tell build_runner to generate mocks for DietService
@GenerateMocks([DietService])
void main() {
  // Declare mock variables
  late MockDietService mockDietService;

  // Helper function to build the widget with injected mocks
  Widget createUpdateGoalsScreenWithMocks() {
    // Using Provider for injection - adapt if needed
    return Provider<DietService>.value(
      value: mockDietService,
      child: MaterialApp(
        home: UpdateGoalsScreen(),
      ),
    );
  }

  // setUp runs before each test
  setUp(() {
    // Create fresh mock instance
    mockDietService = MockDietService();

    // --- Default Stubbing ---
    // Stub getDietGoals to return some initial values when screen loads
    when(mockDietService.getDietGoals()).thenAnswer((_) async => {
      'calorieGoal': 2000.0, // Use double/num consistent with service
      'proteinGoal': 150.0,
      'carbsGoal': 250.0,
      'fatGoal': 60.0,
    });

    // Stub setDietGoals for success
    when(mockDietService.setDietGoals(
      calorieGoal: anyNamed('calorieGoal'),
      proteinGoal: anyNamed('proteinGoal'),
      carbsGoal: anyNamed('carbsGoal'),
      fatGoal: anyNamed('fatGoal'),
    )).thenAnswer((_) async => Future.value());
  });

  // --- Test Cases ---
  testWidgets('UpdateGoalsScreen - Saves valid goals', (WidgetTester tester) async {
    // Arrange: Pump the screen with mocks injected
    await tester.pumpWidget(createUpdateGoalsScreenWithMocks());
    // Wait for getDietGoals to complete and fields to populate
    await tester.pumpAndSettle();

    // Find fields and button (adjust finders if needed)
    final caloriesField = find.widgetWithText(TextFormField, 'Calories (kcal)');
    final proteinField = find.widgetWithText(TextFormField, 'Protein (g)');
    final carbsField = find.widgetWithText(TextFormField, 'Carbs (g)');
    final fatField = find.widgetWithText(TextFormField, 'Fat (g)');
    final saveButton = find.widgetWithText(ElevatedButton, 'Save Goals');

    // Check fields are present
    expect(caloriesField, findsOneWidget);
    expect(proteinField, findsOneWidget);
    expect(carbsField, findsOneWidget);
    expect(fatField, findsOneWidget);
    expect(saveButton, findsOneWidget);

    // Act: Enter new valid data (use clear: true if fields have initial values)
    await tester.enterText(caloriesField, '2200');
    await tester.enterText(proteinField, '160');
    await tester.enterText(carbsField, '270');
    await tester.enterText(fatField, '70');
    await tester.pump(); // Update UI

    // Act: Tap Save button
    await tester.tap(saveButton);
    await tester.pumpAndSettle(); // Allow time for setDietGoals and potential navigation

    // Assert: Verify setDietGoals was called on the mock service with correct values
    // Ensure the types match what setDietGoals expects (e.g., double vs int)
    verify(mockDietService.setDietGoals(
      calorieGoal: 2200.0,
      proteinGoal: 160.0,
      carbsGoal: 270.0,
      fatGoal: 70.0,
    )).called(1);

    // Assert: Check if screen popped after saving (common behavior)
    expect(find.byType(UpdateGoalsScreen), findsNothing, reason: "Screen should pop after saving goals.");
  });

  testWidgets('UpdateGoalsScreen - Shows validation errors for invalid input', (WidgetTester tester) async {
    // Arrange: Pump the screen with mocks injected
    await tester.pumpWidget(createUpdateGoalsScreenWithMocks());
    await tester.pumpAndSettle(); // Wait for initial load

    // Find fields and button
    final caloriesField = find.widgetWithText(TextFormField, 'Calories (kcal)');
    final proteinField = find.widgetWithText(TextFormField, 'Protein (g)');
    final saveButton = find.widgetWithText(ElevatedButton, 'Save Goals');

    // Act: Enter invalid data into one field and clear another
    await tester.enterText(caloriesField, 'invalid text');
    await tester.enterText(proteinField, ''); // Empty field
    await tester.pump();

    // Act: Tap Save button
    await tester.tap(saveButton);
    await tester.pump(); // Trigger validation and UI rebuild

    // Assert: Check for expected validation error messages
    // IMPORTANT: Match these strings exactly with your validators
    expect(find.text('Please enter a valid number'), findsWidgets, reason: "Should show validation error for non-numeric input."); // May find multiple if other fields also use this
    expect(find.text('Please enter a value'), findsWidgets, reason: "Should show validation error for empty fields."); // May find multiple

    // Assert: Verify setDietGoals was NOT called because validation failed
    verifyNever(mockDietService.setDietGoals(
      calorieGoal: anyNamed('calorieGoal'),
      proteinGoal: anyNamed('proteinGoal'),
      carbsGoal: anyNamed('carbsGoal'),
      fatGoal: anyNamed('fatGoal'),
    ));
  });
}