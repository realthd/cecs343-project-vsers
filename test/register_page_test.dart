import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/authentication/RegisterPage.dart';
import 'package:vsers/firebase/Authentication.dart'; // Real Authentication service
// Import UserDb if RegisterPage uses it, otherwise remove
import 'package:vsers/firebase/UserDb.dart';
// Import the page navigated to after successful registration (e.g., WorkoutGoalsPage or UserHomepage)
import 'package:vsers/components/workoutGoals.dart'; // Example destination

// Import the generated mocks for this file
import 'register_page_test.mocks.dart';

// Tell build_runner to generate mocks for services used by RegisterPage
@GenerateMocks([AuthenticationHelper, UserDatabaseService]) // Add/remove as needed
void main() {
  // Declare mock variables
  late MockAuthenticationHelper mockAuthService;
  late MockUserDatabaseService mockUserDbService; // If used

  // Helper function to build the widget with injected mocks
  Widget createRegisterScreenWithMocks() {
    // Using Provider for injection - adapt if needed
    return MultiProvider(
      providers: [
        Provider<AuthenticationHelper>.value(value: mockAuthService),
        // Provide UserDb mock ONLY if RegisterPage uses it directly
        Provider<UserDatabaseService>.value(value: mockUserDbService),
      ],
      child: MaterialApp(
        home: SignupPage(), // Assuming SignupPage is the entry widget in RegisterPage.dart
        // Mock the destination route if needed for verification
        routes: {
          '/workoutGoals': (context) => Scaffold(body: Center(child: Text('Mock Workout Goals Page'))),
        },
      ),
    );
  }

  // setUp runs before each test
  setUp(() {
    // Create fresh mock instances
    mockAuthService = MockAuthenticationHelper();
    mockUserDbService = MockUserDatabaseService(); // If used

    // --- Default Stubbing ---
    // Stub successful sign up
    when(mockAuthService.signUp(
      email: anyNamed('email'),
      password: anyNamed('password'),
      username: anyNamed('username'),
      firstname: anyNamed('firstname'),
      lastname: anyNamed('lastname'),
      isAdmin: anyNamed('isAdmin'),
    )).thenAnswer((_) async => {'error': null, 'isAdmin': false, 'uid': 'mock_user_123'}); // Simulate success with UID

    // Stub UserDb service if it's called after signup (e.g., to create user profile)
    when(mockUserDbService.createUserProfile(
      userId: anyNamed('userId'),
      username: anyNamed('username'),
      firstname: anyNamed('firstname'),
      lastname: anyNamed('lastname'),
      email: anyNamed('email'),
      role: anyNamed('role'),
    )).thenAnswer((_) async => Future.value()); // Simulate success
  });

  // --- Test Cases ---
  testWidgets('RegisterPage - Successful Registration', (WidgetTester tester) async {
    // Arrange: Pump the register screen with mocks injected
    await tester.pumpWidget(createRegisterScreenWithMocks());

    // Find form fields by their label text (adjust if needed)
    final firstNameField = find.widgetWithText(TextFormField, 'First Name');
    final lastNameField = find.widgetWithText(TextFormField, 'Last Name');
    final usernameField = find.widgetWithText(TextFormField, 'Username');
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    // Adjust button finder based on your actual button (ElevatedButton, FilledButton, etc.)
    final registerButton = find.widgetWithText(FilledButton, 'Register');

    // Basic check that fields are present
    expect(firstNameField, findsOneWidget);
    // ... check other fields ...
    expect(registerButton, findsOneWidget);

    // Act: Enter valid data into fields
    await tester.enterText(firstNameField, 'Test');
    await tester.enterText(lastNameField, 'User');
    await tester.enterText(usernameField, 'testuser');
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.pump(); // Update UI state

    // Act: Tap the register button
    await tester.tap(registerButton);
    // pumpAndSettle allows time for async calls (signUp, createUserProfile) and navigation
    await tester.pumpAndSettle();

    // Assert: Verify signUp was called on the mock service with correct arguments
    verify(mockAuthService.signUp(
      email: 'test@example.com',
      password: 'password123',
      username: 'testuser',
      firstname: 'Test',
      lastname: 'User',
      isAdmin: false, // Assuming default is false
    )).called(1);

    // Assert: Verify createUserProfile was called (if applicable)
    verify(mockUserDbService.createUserProfile(
      userId: 'mock_user_123', // From the stubbed signUp return
      username: 'testuser',
      firstname: 'Test',
      lastname: 'User',
      email: 'test@example.com',
      role: 'user', // Assuming default role
    )).called(1);

    // Assert: Verify navigation occurred (e.g., to WorkoutGoalsPage)
    expect(find.text('Mock Workout Goals Page'), findsOneWidget, reason: "Should navigate to Workout Goals page after registration.");
    expect(find.byType(SignupPage), findsNothing, reason: "Register page should be removed after navigation.");
  });

  testWidgets('RegisterPage - Shows validation errors for empty fields', (WidgetTester tester) async {
    // Arrange: Pump the register screen with mocks injected
    await tester.pumpWidget(createRegisterScreenWithMocks());

    // Find the register button
    final registerButton = find.widgetWithText(FilledButton, 'Register'); // Adjust finder
    expect(registerButton, findsOneWidget);

    // Act: Tap register button without entering any data
    await tester.tap(registerButton);
    await tester.pump(); // Trigger validation and UI rebuild

    // Assert: Check for expected validation error messages
    // IMPORTANT: Match these strings exactly with the error messages in your TextFormField validators
    expect(find.text('Please enter your Firstname'), findsOneWidget);
    expect(find.text('Please enter your Lastname'), findsOneWidget);
    expect(find.text('Please enter a username'), findsOneWidget);
    expect(find.text('Please enter an email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    // Add checks for specific format errors if you enter invalid data (e.g., bad email)

    // Assert: Verify signUp was NOT called because validation failed
    verifyNever(mockAuthService.signUp(
      email: anyNamed('email'),
      password: anyNamed('password'),
      username: anyNamed('username'),
      firstname: anyNamed('firstname'),
      lastname: anyNamed('lastname'),
      isAdmin: anyNamed('isAdmin'),
    ));

    // Assert: Verify createUserProfile was also NOT called
    verifyNever(mockUserDbService.createUserProfile(
      userId: anyNamed('userId'),
      username: anyNamed('username'),
      firstname: anyNamed('firstname'),
      lastname: anyNamed('lastname'),
      email: anyNamed('email'),
      role: anyNamed('role'),
    ));
  });
}