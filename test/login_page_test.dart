// test/register_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider; // Hide conflicting name if necessary

// Import your actual page and services
import 'package:vsers/authentication/LoginPage.dart';
import 'package:vsers/firebase/Authentication.dart';
import 'package:vsers/firebase/UserDb.dart';
import 'package:vsers/authentication/RegisterPage.dart';

// Import generated mocks from the previous example (or regenerate if needed)
// Ensure UserCredential and User are also mocked if Authentication returns them
@GenerateMocks([AuthenticationHelper, UserDatabaseService, UserCredential, User])

import 'auth_test.mocks.dart'; // Using the mocks generated previously
// --- Mock Provider Setup (EXAMPLE ONLY) ---
// You MUST replace this with your actual dependency injection setup.
// This is a placeholder showing how you might provide mocks.
// If using Provider, you'd wrap MaterialApp with MultiProvider.
// If using GetIt, you'd register mocks before running the test.
late MockAuthentication mockAuthService;
late MockUserDb mockUserDbService;

Widget createRegisterPageWithMocks() {
  // Reset mocks for each test setup if needed
  mockAuthService = MockAuthentication();
  mockUserDbService = MockUserDb();

  // --- Stub Success Scenario ---
  final mockFirebaseUser = MockUser();
  when(mockFirebaseUser.uid).thenReturn('mock_uid_123');
  final mockUserCredential = MockUserCredential();
  when(mockUserCredential.user).thenReturn(mockFirebaseUser);

  when(mockAuthService.signUp(any, any))
      .thenAnswer((_) async => mockUserCredential);
  // Adjust parameters for createUserDoc based on your actual method
  when(mockUserDbService.createUserDoc(
    uid: anyNamed('uid'),
    email: anyNamed('email'),
    role: anyNamed('role'), // Ensure 'role' is passed if needed
    firstName: anyNamed('firstName'),
    // Add other fields like lastName, dob, etc., if they are part of the form
  )).thenAnswer((_) async {}); // Simulate success
  // --- End Stubs ---

  // Example using simple constructor injection (Adapt to your DI):
  // return RegisterPage(authService: mockAuthService, userDbService: mockUserDbService);

  // Example Placeholder: You MUST replace this with how you provide your mocks.
  // Often involves wrapping with Provider or setting up GetIt.
  return MaterialApp(
    home: Scaffold( // Scaffold is often needed for basic layout elements
      // Assuming RegisterPage can access the mocks somehow (e.g., via Provider.of or GetIt)
      body: SignupPage(),
    ),
  );
}
// --- End Mock Provider Setup ---


void main() {
  // Optional: Setup mocks once if they don't change between tests in a group
  // setUpAll(() {
  //   // Initialize and register mocks using your DI solution (e.g., GetIt)
  // });

  group('RegisterPage Widget Tests', () {
    testWidgets('Successful registration calls services and potentially navigates', (WidgetTester tester) async {
      // Arrange: Pump the widget with mocked dependencies
      await tester.pumpWidget(createRegisterPageWithMocks()); // Use the helper

      // Find TextFields (adjust finders based on Keys, text labels, etc.)
      final emailField = find.widgetWithText(TextField, 'Email'); // Adjust finder
      final passwordField = find.widgetWithText(TextField, 'Password'); // Adjust finder
      final firstNameField = find.widgetWithText(TextField, 'First Name'); // Adjust finder
      // Add finders for other fields (lastName, dob, confirm password...)

      final registerButton = find.widgetWithText(ElevatedButton, 'Register'); // Adjust finder

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(firstNameField, findsOneWidget);
      expect(registerButton, findsOneWidget);

      // Act: Enter text and tap the button
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(firstNameField, 'Test');
      // Enter text in other fields...
      await tester.pump(); // Allow state to update if necessary

      await tester.tap(registerButton);
      await tester.pumpAndSettle(); // Wait for async operations (like sign up) and animations

      // Assert: Verify that the mocked services were called correctly
      verify(mockAuthService.signUp('test@example.com', 'password123')).called(1);

      // Verify createUserDoc was called with expected data extracted from the fields
      verify(mockUserDbService.createUserDoc(
        uid: 'mock_uid_123', // Comes from the stubbed UserCredential
        email: 'test@example.com',
        role: 'user', // Or whatever default/selected role is expected
        firstName: 'Test',
        // Add verification for other fields...
      )).called(1);

      // Assert Navigation (Optional): Check if navigation occurred
      // This depends heavily on your navigation logic.
      // Example: expect(find.text('Welcome!'), findsOneWidget); // If it navigates to a page with 'Welcome!'
      // Or verify mock Navigator: // navigatorObserver.didPush(any, any);
    });

    testWidgets('Shows error message if sign up fails', (WidgetTester tester) async {
      // Arrange: Stub services for failure
      await tester.pumpWidget(createRegisterPageWithMocks()); // Use helper, but override stubs

      // Override the auth service stub for this specific test
      final exception = FirebaseAuthException(
          code: 'email-already-in-use', message: 'Email already exists');
      when(mockAuthService.signUp(any, any)).thenThrow(exception);

      // Find fields and button
      final emailField = find.widgetWithText(TextField, 'Email'); // Adjust finder
      final passwordField = find.widgetWithText(TextField, 'Password'); // Adjust finder
      final firstNameField = find.widgetWithText(TextField, 'First Name'); // Adjust finder
      final registerButton = find.widgetWithText(ElevatedButton, 'Register'); // Adjust finder

      // Act: Enter text and tap button
      await tester.enterText(emailField, 'existing@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(firstNameField, 'Test');
      await tester.tap(registerButton);
      await tester.pumpAndSettle(); // Allow time for error handling

      // Assert: Verify sign up was called
      verify(mockAuthService.signUp('existing@example.com', 'password123')).called(1);

      // Assert: Verify createUserDoc was NOT called
      verifyNever(mockUserDbService.createUserDoc(
        uid: anyNamed('uid'),
        email: anyNamed('email'),
        role: anyNamed('role'),
        firstName: anyNamed('firstName'),
      ));

      // Assert: Check for error message (adjust finder based on how you show errors)
      expect(find.textContaining('Email already exists'), findsOneWidget); // Or check for a specific error widget
    });

    // Add more tests for:
    // - Validation errors (empty fields, invalid email format, password mismatch)
    // - Failure during createUserDoc call
  });
}