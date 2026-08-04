import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  final _nameController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response =
          await ApiService().get('${ApiConstants.baseUrl}/profile');
      setState(() {
        _user = User.fromJson(response as Map<String, dynamic>);
        _nameController.text = _user!.fullName ?? '';
        _timezoneController.text = _user!.timezone;
        _currencyController.text = _user!.currency;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    try {
      await ApiService().put('${ApiConstants.baseUrl}/profile', {
        'fullName': _nameController.text,
        'timezone': _timezoneController.text,
        'currency': _currencyController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _user?.email.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _timezoneController,
                    decoration: const InputDecoration(labelText: 'Timezone'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _currencyController,
                    decoration: const InputDecoration(labelText: 'Currency'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timezoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }
}
