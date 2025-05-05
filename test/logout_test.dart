import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // Using Provider for DI example
import 'package:vsers/user/UserSettings.dart'; // Screen where logout is triggered
import 'package:vsers/firebase/Authentication.dart'; // Real Authentication service
import 'package:vsers/authentication/LoginPage.dart'; // For navigation check

// Import the generated mocks for this file
import 'logout_test.mocks.dart';

// Tell build_runner to generate mocks for AuthenticationHelper
@GenerateMocks([AuthenticationHelper])
void main() {
  // Declare mock variables
  late MockAuthenticationHelper mockAuthService;

  // Helper function to build the widget with injected mocks
  Widget createSettingsScreenWithMocks() {
    return Provider<AuthenticationHelper>.value(
      value: mockAuthService,
      child: MaterialApp(
        home: UserSettings(),
        routes: {
          '/login': (context) => Scaffold(body: Center(child: Text('Mock Login Page'))),
        },
      ),
    );
  }

  // setUp runs before each test
  setUp(() {
    mockAuthService = MockAuthenticationHelper();
    print('--- TEST SETUP --- Mock AuthService HashCode: ${mockAuthService.hashCode}');
    // Stub the signOut method
    when(mockAuthService.signOut()).thenAnswer((_) async {
      print('--- MOCK --- signOut() CALLED!');
      // Simulate a tiny delay, closer to a real async operation
      await Future.delayed(Duration(milliseconds: 10));
      return Future.value();
    });
  });

  // --- Test Cases ---
  testWidgets('Logout Test - Tapping Logout shows confirmation dialog', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createSettingsScreenWithMocks());

    // Act
    final logoutTile = find.widgetWithText(ListTile, 'Logout');
    expect(logoutTile, findsOneWidget);
    await tester.tap(logoutTile);
    await tester.pumpAndSettle(); // Wait for dialog

    // Assert
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Confirm'), findsOneWidget);
    // Verify not called yet
    verifyNever(mockAuthService.signOut());
  });

  testWidgets('Logout Test - Confirming Logout calls signOut and navigates', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createSettingsScreenWithMocks());
    verifyNever(mockAuthService.signOut()); // Ensure not called initially

    // Act: Show dialog
    await tester.tap(find.widgetWithText(ListTile, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget); // Dialog is up

    // Act: Tap Confirm
    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));

    // ** MODIFIED PUMPING **
    // Pump slightly longer than the simulated delay in the mock's signOut
    // This gives the async signOut call time to complete AND register with Mockito
    await tester.pump(const Duration(milliseconds: 50)); // Or Duration.zero if the delay isn't needed

    // Assert: Verify the mock call NOW, before settling navigation
    verify(mockAuthService.signOut()).called(1);

    // NOW, let navigation and animations finish
    await tester.pumpAndSettle();

    // Assert: Verify navigation occurred
    expect(find.text('Mock Login Page'), findsOneWidget, reason: "Should navigate to the Login Page after logout.");
    expect(find.byType(UserSettings), findsNothing, reason: "UserSettings screen should be removed after navigation.");
  });
}