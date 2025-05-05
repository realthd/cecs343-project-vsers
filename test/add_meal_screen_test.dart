import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/user/AddMealScreen.dart';
import 'package:vsers/firebase/FoodService.dart';
import 'package:vsers/firebase/DietService.dart';

// Import the generated mocks for this file
import 'add_meal_screen_test.mocks.dart';

// Tell build_runner to generate mocks for these classes
@GenerateMocks([FoodService, DietService])
void main() {
  // Declare mock variables
  late MockFoodService mockFoodService;
  late MockDietService mockDietService;

  // Helper function to build the widget with injected mocks
  Widget createAddMealScreenWithMocks() {
    // Using Provider for injection - adapt if using GetIt, Riverpod, etc.
    // This assumes AddMealScreen uses Provider.of<FoodService>(context) internally
    return MultiProvider(
      providers: [
        Provider<FoodService>.value(value: mockFoodService),
        Provider<DietService>.value(value: mockDietService),
      ],
      child: MaterialApp(
        home: AddMealScreen(),
      ),
    );
  }

  // setUp runs before each test
  setUp(() {
    // Create fresh mock instances for each test
    mockFoodService = MockFoodService();
    mockDietService = MockDietService();

    // --- Default Stubbing ---
    // Stub getPresetFoods to return a specific list for tests
    when(mockFoodService.getPresetFoods()).thenAnswer((_) async => [
      {
        'id': 'preset1', 'name': 'Oatmeal with Banana', // Name used in test 1
        'calories': 280, 'protein': 8, 'carbs': 55, 'fat': 4,
        'mealType': 'breakfast', 'isUserCreated': false
      },
      {
        'id': 'preset2', 'name': 'Chicken Salad',
        'calories': 350, 'protein': 30, 'carbs': 10, 'fat': 20,
        'mealType': 'lunch', 'isUserCreated': false
      }
    ]);

    // Stub addMeal to simulate success
    when(mockDietService.addMeal(any)).thenAnswer((_) async => Future.value());

    // Stub addUserCreatedMeal (if used by AddMealScreen's custom flow)
    when(mockFoodService.addUserCreatedMeal(any)).thenAnswer((_) async => 'custom_meal_id');
  });

  // --- Test Cases ---
  testWidgets('AddMealScreen - Adds a preset food', (WidgetTester tester) async {
    // Arrange: Pump the screen with mocks injected
    await tester.pumpWidget(createAddMealScreenWithMocks());
    // Wait for async operations like getPresetFoods to complete and UI to build
    await tester.pumpAndSettle();

    // Act: Find and tap the preset food item
    // Finder uses the 'name' from the stubbed data
    final presetFoodItem = find.text('Oatmeal with Banana');
    expect(presetFoodItem, findsOneWidget, reason: "Preset food 'Oatmeal with Banana' should be displayed based on stubbed data.");

    await tester.tap(presetFoodItem);
    await tester.pumpAndSettle(); // Allow for potential dialog/navigation/snackbar

    // Assert: Verify addMeal was called on the mock DietService with correct data
    final capturedData = verify(mockDietService.addMeal(captureAny)).captured.single as Map<String, dynamic>;
    expect(capturedData['name'], 'Oatmeal with Banana');
    expect(capturedData['calories'], 280);
    // Add checks for other properties if needed

    // Assert: Check for success indication (e.g., Snackbar or navigation pop)
    // Example: expect(find.text('Meal added successfully'), findsOneWidget);
    // Example: expect(find.byType(AddMealScreen), findsNothing); // if it pops
  });

  testWidgets('AddMealScreen - Adds a custom meal', (WidgetTester tester) async {
    // Arrange: Pump the screen with mocks injected
    await tester.pumpWidget(createAddMealScreenWithMocks());
    await tester.pumpAndSettle(); // Wait for initial build

    // Act: Find and tap the 'Add Custom Meal' button/icon
    // IMPORTANT: Adjust the finder based on your actual UI implementation
    final customMealButton = find.byIcon(Icons.add); // Assuming an Icon button
    expect(customMealButton, findsOneWidget, reason: "Add custom meal button/icon should be present.");

    await tester.tap(customMealButton);
    await tester.pumpAndSettle(); // Wait for dialog animation

    // Act: Find fields within the dialog and enter data
    // IMPORTANT: Adjust finders if your dialog uses different widgets or keys
    final nameField = find.widgetWithText(TextFormField, 'Meal Name');
    final caloriesField = find.widgetWithText(TextFormField, 'Calories');
    final proteinField = find.widgetWithText(TextFormField, 'Protein (g)');
    final carbsField = find.widgetWithText(TextFormField, 'Carbs (g)');
    final fatField = find.widgetWithText(TextFormField, 'Fat (g)');
    final addButton = find.widgetWithText(TextButton, 'Add'); // Find 'Add' button inside the dialog

    expect(nameField, findsOneWidget);
    expect(caloriesField, findsOneWidget);
    // ... check other fields exist ...
    expect(addButton, findsOneWidget);

    await tester.enterText(nameField, 'Custom Test Meal');
    await tester.enterText(caloriesField, '450');
    await tester.enterText(proteinField, '35');
    await tester.enterText(carbsField, '40');
    await tester.enterText(fatField, '18');
    // Handle meal type selection if present in dialog (e.g., dropdown)
    await tester.pump(); // Update UI after entering text

    // Act: Tap the Add button in the dialog
    await tester.tap(addButton);
    await tester.pumpAndSettle(); // Wait for async operations (addMeal) and dialog close

    // Assert: Verify addMeal was called on the mock DietService with custom data
    final capturedData = verify(mockDietService.addMeal(captureAny)).captured.single as Map<String, dynamic>;
    expect(capturedData['name'], 'Custom Test Meal');
    expect(capturedData['calories'], 450);
    expect(capturedData['protein'], 35);
    // Add checks for other properties if needed

    // Assert: Verify addUserCreatedMeal was called (if applicable)
    // verify(mockFoodService.addUserCreatedMeal(any)).called(1);

    // Assert: Check for success indication (e.g., Snackbar or navigation pop)
    // Example: expect(find.text('Meal added successfully'), findsOneWidget);
  });
}