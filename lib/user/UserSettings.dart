/// A Flutter widget module that provides user profile settings and preferences,
/// including account management, notifications, privacy controls, theme options, and logout.
///
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ** Import Provider **
import 'package:vsers/authentication/LoginPage.dart';
import 'package:vsers/firebase/Authentication.dart'; // Import your AuthenticationHelper class

/// A stateless widget that displays a list of settings options for the user profile.
///
/// Attributes:
/// - key: An optional unique identifier for the widget.
class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  /// Builds the UI for the UserSettings screen.
  ///
  /// Args:
  /// - context (BuildContext): The context in which the widget is built.
  ///
  /// Returns:
  /// - Widget: A Scaffold containing a list of user settings options.
  ///
  /// Summary:
  /// Constructs a list view of user settings categories such as account, notifications,
  /// privacy, theme, and logout, and returns the assembled Scaffold widget.
  @override
  Widget build(BuildContext context) {
    // ** Get the AuthenticationHelper instance via Provider **
    // We get it here once if multiple actions might need it, or get it inside the specific handler.
    // Using listen: false is usually appropriate if you only need it for actions, not for rebuilding the UI.
    final authService = Provider.of<AuthenticationHelper>(context, listen: false);
    // *****************************************************

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      /// A list of common user settings options.
      body: ListView(
        children: [
          /// Account settings option.
          InkWell(
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('Account'),
              subtitle: Text('Profile settings'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: () {},
          ),
          /// Notification preferences option.
          InkWell(
            child: const ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              subtitle: Text('Push, email preferences'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: (){},
          ),
          /// Privacy control settings.
          InkWell(
            child: const ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy'),
              subtitle: Text('Manage data sharing'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: () {},
          ),
          /// Theme switching option.
          InkWell(
            child: const ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Theme'),
              subtitle: Text('Light / Dark Mode'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: () {},
          ),
          /// Logout action.
          InkWell(
            child: const ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
            onTap: () {
              // Pass the authService instance obtained above to the dialog confirmation
              _showConfirmationDialog(
                context,
                title: 'Sign Out',
                content: 'Are you sure you want to sign out?',
                onConfirm: () async {
                  // Use the authService instance from Provider
                  try {
                    print('--- WIDGET ACTION --- Calling signOut() on AuthService HashCode: ${authService.hashCode}'); // Add this line
                    await authService.signOut(); // Use the instance obtained in onTap
                    print('--- WIDGET ACTION --- signOut() call completed');
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()), // Use const if LoginPage allows
                            (route) => false,
                      );
                    }
                  } catch (e) {
                    // Optional: Show error to user if sign out fails
                    print("Sign out error: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign out failed: ${e.toString()}'))
                      );
                    }
                  }
                },
              );
            },
          ),
          // Consider adding the delete account dialog trigger similarly if needed
          // ListTile(
          //   leading: Icon(Icons.delete_forever, color: Colors.red),
          //   title: Text('Delete Account', style: TextStyle(color: Colors.red)),
          //   onTap: () {
          //      _showDeleteAccountDialog(context, authService); // Pass the authService
          //   }
          // )
        ],
      ),
    );
  }

  /// Shows a confirmation dialog.
  /// [onConfirm] is now responsible for closing the dialog IF needed before async work.
  void _showConfirmationDialog(BuildContext context, {required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      // barrierDismissible: false, // Optional: Prevent closing by tapping outside
      builder: (BuildContext dialogContext) { // Use a different context name for clarity
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog *before* calling onConfirm
                onConfirm(); // Call the provided confirmation logic
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the delete account dialog. Needs AuthenticationHelper instance.
  void _showDeleteAccountDialog(BuildContext context, AuthenticationHelper authService) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Different context name
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Type in your password to confirm account deletion. This cannot be undone.'),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text;
                Navigator.of(dialogContext).pop(); // Close dialog before async work

                if (password.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password is required to delete account.'))
                    );
                  }
                  return;
                }

                try {
                  // Use the authService instance from Provider
                  await authService.deleteAccount(password);
                  // Navigate after successful deletion
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  // Handle deletion errors (e.g., wrong password)
                  print("Delete account error: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete account: ${e.toString()}'))
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}