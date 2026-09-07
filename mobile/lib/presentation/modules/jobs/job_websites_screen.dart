import 'package:flutter/material.dart';
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
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  Future<void> _loadWebsites() async {
    try {
      final response =
          await ApiService().get('${ApiConstants.jobsUrl}/websites');
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

  void _resetForm() {
    _nameController.clear();
    _urlController.clear();
    _notesController.clear();
    setState(() {
      _status = 'active';
      _editingId = null;
    });
  }

  void _editWebsite(JobWebsite w) {
    _nameController.text = w.name;
    _urlController.text = w.url ?? '';
    _notesController.text = w.notes ?? '';
    setState(() {
      _status = w.status;
      _editingId = w.id;
    });
  }

  Future<void> _saveWebsite() async {
    if (_nameController.text.isEmpty) return;
    final body = {
      'name': _nameController.text,
      'url': _urlController.text,
      'notes': _notesController.text,
      'status': _status,
    };
    try {
      if (_editingId != null) {
        await ApiService()
            .put('${ApiConstants.jobsUrl}/websites?id=$_editingId', body);
      } else {
        await ApiService().post('${ApiConstants.jobsUrl}/websites', body);
      }
      _resetForm();
      _loadWebsites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _confirmDelete(JobWebsite w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Website'),
        content: Text('Delete "${w.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService().delete('${ApiConstants.jobsUrl}/websites?id=${w.id}');
      if (_editingId == w.id) _resetForm();
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 8),
                      if (_websites.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No websites yet')),
                        )
                      else
                        ..._websites.map((w) => _buildWebsiteCard(w)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildFormCard() {
    final isEditing = _editingId != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Website' : 'Add Website',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _saveWebsite,
                    child: Text(isEditing ? 'Update Website' : 'Add Website'),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _resetForm,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(JobWebsite w) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(w.status).withValues(alpha: 0.2),
          child: Icon(Icons.language, color: _statusColor(w.status)),
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
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editWebsite(w),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(w),
            ),
          ],
        ),
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
