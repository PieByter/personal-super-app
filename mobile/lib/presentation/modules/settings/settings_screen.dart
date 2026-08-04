import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _biometric = false;
  bool _notifications = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/profile'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Coming soon'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Require biometric to open app'),
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Reminders and alerts'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('JSON / CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/export'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await ApiService().clearToken();
    if (mounted) context.go('/login');
  }
}
