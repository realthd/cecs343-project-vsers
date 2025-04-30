/// A Flutter widget module that provides user profile settings and preferences, 
/// including account management, notifications, privacy controls, theme options, and logout.
/// 
import 'package:flutter/material.dart';
import 'package:vsers/authentication/LoginPage.dart';
import 'package:vsers/firebase/Authentication.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      /// A list of common user settings options.
      body: ListView(
        children: [
          /// Account settings option.
          InkWell(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Account'),
              subtitle: Text('Profile settings'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: () {},
          ),
          /// Notification preferences option.
          InkWell(
            child: ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              subtitle: Text('Push, email preferences'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: (){},
          ),
          /// Privacy control settings.
          InkWell(
            child: ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy'),
              subtitle: Text('Manage data sharing'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: () {},
          ),
          /// Theme switching option.
          InkWell(
            child: ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Theme'),
              subtitle: Text('Light / Dark Mode'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            onTap: () {},
          ),
          /// Logout action.
          InkWell(
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
            onTap: () {
              _showConfirmationDialog(
                context,
                title: 'Sign Out',
                content: 'Are you sure you want to sign out?',
                onConfirm: () async {
                  Navigator.pop(context);
                  await AuthenticationHelper().signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login screen
                        (route) => false,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  void _showConfirmationDialog(BuildContext context, {required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Type in your password to confirm the delete.'),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AuthenticationHelper().deleteAccount(passwordController.text);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login screen
                    (route) => false,
              );            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
