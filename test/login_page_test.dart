import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vsers/authentication/LoginPage.dart';

void main() {
  testWidgets('LoginPage UI loads and validates input', (WidgetTester tester) async {
    // Pump the LoginPage widget inside a MaterialApp (required for navigation and themes)
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    // Check if the essential elements are present
    expect(find.text('Log in'), findsOneWidget);
    expect(find.widgetWithIcon(TextFormField, Icons.alternate_email), findsOneWidget); // Email field
    expect(find.widgetWithIcon(TextFormField, Icons.lock), findsOneWidget); // Password field
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);

    // Try submitting empty form and check for validation errors
    await tester.tap(find.text('Login'));
    await tester.pump(); // Let the validator messages appear

    expect(find.text('Please enter an email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(0), 'invalidemail');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
