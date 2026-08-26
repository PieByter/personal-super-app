import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/job.dart';
import '../../widgets/app_drawer.dart';

class JobWebsitesScreen extends StatefulWidget {
  const JobWebsitesScreen({super.key});

  @override
  State<JobWebsitesScreen> createState() => _JobWebsitesScreenState();
}

class _JobWebsitesScreenState extends State<JobWebsitesScreen> {
  List<JobWebsite> _websites = [];
  bool _isLoading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  Future<void> _loadWebsites() async {
    try {
      final response = await ApiService().get('${ApiConstants.jobsUrl}/websites');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _websites = data.map((e) => JobWebsite.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    return switch (status) {
      'active' => Colors.green,
      'inactive' => Colors.orange,
      'archived' => Colors.red,
      _ => Colors.grey,
    };
  }

  Future<void> _addWebsite() async {
    if (_nameController.text.isEmpty) return;
    try {
      await ApiService().post('${ApiConstants.jobsUrl}/websites', {
        'name': _nameController.text,
        'url': _urlController.text,
        'notes': _notesController.text,
        'status': _status,
      });
      _nameController.clear();
      _urlController.clear();
      _notesController.clear();
      _status = 'active';
      _loadWebsites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteWebsite(String id) async {
    try {
      await ApiService().delete('${ApiConstants.jobsUrl}/websites?id=$id');
      _loadWebsites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Websites'),
      ),
      drawer: const AppDrawer(currentRoute: '/jobs'),
      body: RefreshIndicator(
        onRefresh: _loadWebsites,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Website Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(labelText: 'URL'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'archived', child: Text('Archived')),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'active'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _addWebsite,
                    child: const Text('Add Website'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _websites.isEmpty
                          ? const Center(child: Text('No websites yet'))
                          : ListView.builder(
                              itemCount: _websites.length,
                              itemBuilder: (context, index) {
                                final w = _websites[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _statusColor(w.status)
                                          .withValues(alpha: 0.2),
                                      child: Icon(Icons.language,
                                          color: _statusColor(w.status)),
                                    ),
                                    title: Text(w.name),
                                    subtitle: Text(
                                      'Total Applications: ${w.totalApplications} • Last applied: ${w.lastAppliedAt ?? "-"}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (w.url != null && w.url!.isNotEmpty)
                                          IconButton(
                                            tooltip: 'Open website',
                                            icon: const Icon(Icons.open_in_new),
                                            onPressed: () => _openUrl(w.url!),
                                          ),
                                        IconButton(
                                          tooltip: 'Delete',
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteWebsite(w.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/jobs'),
        backgroundColor: AppColors.jobs,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
