import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isSavingPassword = false;

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
        'avatarUrl': _user?.avatarUrl,
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

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password must be at least 8 characters'),
          ),
        );
      }
      return;
    }
    setState(() => _isSavingPassword = true);
    try {
      await ApiService().post('${ApiConstants.baseUrl}/profile/password', {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 70,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    setState(() => _user = _user?.copyWith(avatarUrl: dataUri));
    // Save immediately so the avatar persists.
    try {
      await ApiService().put('${ApiConstants.baseUrl}/profile', {
        'avatarUrl': dataUri,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated')),
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

  /// Returns a provider for the avatar, or null to show the initial letter.
  ImageProvider? _avatarImage() {
    final url = _user?.avatarUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:')) {
      final parts = url.split(',');
      if (parts.length < 2) return null;
      return MemoryImage(base64Decode(parts[1]));
    }
    return NetworkImage(url);
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
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage: _avatarImage(),
                          child: _avatarImage() == null
                              ? Text(
                                  _user?.email.substring(0, 1).toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                              onPressed: _pickAvatar,
                            ),
                          ),
                        ),
                      ],
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
                  const Divider(height: 40),
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password (min 8 chars)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSavingPassword ? null : _changePassword,
                      child: _isSavingPassword
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Change Password'),
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
