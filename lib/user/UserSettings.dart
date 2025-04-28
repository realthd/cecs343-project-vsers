/// A Flutter widget module that provides user profile settings and preferences, 
/// including account management, notifications, privacy controls, theme options, and logout.
/// 
import 'package:flutter/material.dart';
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
        children: const [
          /// Account settings option.
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            subtitle: Text('Profile settings'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          /// Notification preferences option.
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Push, email preferences'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          /// Privacy control settings.
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy'),
            subtitle: Text('Manage data sharing'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          /// Theme switching option.
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme'),
            subtitle: Text('Light / Dark Mode'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          /// Logout action.
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
