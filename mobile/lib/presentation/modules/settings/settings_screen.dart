import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/api_service.dart';
import '../../../data/biometric_service.dart';
import '../../../data/theme_service.dart';
import '../../../data/app_localizations.dart';
import '../../../data/pwa_install_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _biometric = false;
  bool _notifications = true;
  bool _biometricAvailable = false;
  bool _isIndonesian = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await BiometricService().isEnabled();
    final available = await BiometricService().canUseBiometrics();
    final themeMode = ThemeService().mode.value;
    final isIndonesian = LocaleService().locale.value.languageCode == 'id';
    if (mounted) {
      setState(() {
        _biometric = enabled;
        _biometricAvailable = available;
        _darkMode = themeMode == ThemeMode.dark;
        _isIndonesian = isIndonesian;
      });
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await ThemeService().setMode(
      value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> _toggleLanguage(bool isIndonesian) async {
    setState(() => _isIndonesian = isIndonesian);
    await LocaleService().setLocale(
      isIndonesian ? const Locale('id') : const Locale('en'),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value && !_biometricAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Biometric authentication is not available on this device'),
          ),
        );
      }
      return;
    }
    setState(() => _biometric = value);
    await BiometricService().setEnabled(value);
  }

  void _showAccentColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        final current = ThemeService().accentColor.value;
        return AlertDialog(
          title: const Text('Accent Color'),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ThemeService.accentOptions.map((color) {
              final selected = color == current;
              return InkWell(
                onTap: () {
                  ThemeService().setAccentColor(color);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.black54, width: 3)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
            value: _darkMode,
            onChanged: _toggleDarkMode,
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent Color'),
            subtitle: const Text('Customize app theme color'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAccentColorPicker,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_isIndonesian ? 'Bahasa Indonesia' : 'English'),
            trailing: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('EN')),
                ButtonSegment(value: true, label: Text('ID')),
              ],
              selected: {_isIndonesian},
              onSelectionChanged: (s) => _toggleLanguage(s.first),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Require biometric to open app'),
            value: _biometric,
            onChanged: _toggleBiometric,
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
          ValueListenableBuilder<bool>(
            valueListenable: PwaInstallService().canInstall,
            builder: (context, canInstall, _) {
              if (!canInstall) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.download_for_offline_outlined),
                title: const Text('Install App'),
                subtitle: const Text('Add to home screen'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => PwaInstallService().promptInstall(),
              );
            },
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
    await ApiService().clearTokens();
    if (mounted) context.go('/login');
  }
}
