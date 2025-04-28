import 'package:flutter/material.dart';

/// Displays settings and preferences for the user profile,
/// including account management, notifications, privacy, and theme options.
class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

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
