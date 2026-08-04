import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/contact.dart';
import '../../../domain/models/job.dart';

class JobContactsScreen extends StatefulWidget {
  final JobApplication job;
  const JobContactsScreen({super.key, required this.job});

  @override
  State<JobContactsScreen> createState() => _JobContactsScreenState();
}

class _JobContactsScreenState extends State<JobContactsScreen> {
  List<JobContact> _contacts = [];
  bool _isLoading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final response = await ApiService()
          .get('${ApiConstants.jobsUrl}/${widget.job.id}/contacts');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _contacts = data.map((e) => JobContact.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addContact() async {
    if (_nameController.text.isEmpty) return;
    try {
      await ApiService()
          .post('${ApiConstants.jobsUrl}/${widget.job.id}/contacts', {
        'name': _nameController.text,
        'role': _roleController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'linkedinUrl': _linkedinController.text,
        'notes': _notesController.text,
      });
      _nameController.clear();
      _roleController.clear();
      _emailController.clear();
      _phoneController.clear();
      _linkedinController.clear();
      _notesController.clear();
      _loadContacts();
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
      appBar: AppBar(
        title: Text('${widget.job.companyName} Contacts'),
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Add Contact'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _roleController,
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _linkedinController,
                      decoration: const InputDecoration(labelText: 'LinkedIn'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _addContact,
                      child: const Text('Add Contact'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _contacts.isEmpty
                        ? const Center(child: Text('No contacts yet'))
                        : ListView.builder(
                            itemCount: _contacts.length,
                            itemBuilder: (context, index) {
                              final c = _contacts[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.jobs.withValues(alpha: 0.2),
                                    child: const Icon(Icons.person,
                                        color: AppColors.jobs),
                                  ),
                                  title: Text(c.name),
                                  subtitle: Text(
                                    '${c.role ?? ''}\n${c.email ?? ''}\n${c.phone ?? ''}',
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
