import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/job.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/shimmer_list.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  List<JobApplication> _entries = [];
  List<JobWebsite> _websites = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedWebsiteId;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final responses = await Future.wait([
        ApiService().get(ApiConstants.jobsUrl),
        ApiService().get('${ApiConstants.jobsUrl}/websites'),
      ]);
      final jobs = responses[0];
      final websites = responses[1];
      setState(() {
        _entries = (jobs is List ? jobs : [])
            .map((e) => JobApplication.fromJson(e))
            .toList();
        _websites = (websites is List ? websites : [])
            .map((e) => JobWebsite.fromJson(e))
            .toList();
        _isLoading = false;
        _error = null;
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
      'offer' || 'accepted' => Colors.green,
      'interview' || 'technical_test' => Colors.blue,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };
  }

  String? _websiteName(String? websiteId) {
    if (websiteId == null) return null;
    for (final website in _websites) {
      if (website.id == websiteId) return website.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _selectedWebsiteId == null
        ? _entries
        : _entries.where((job) => job.websiteId == _selectedWebsiteId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Tracker'),
        actions: [
          IconButton(
            tooltip: 'Websites',
            icon: const Icon(Icons.language),
            onPressed: () => context.go('/jobs/websites'),
          ),
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.go('/jobs/stats'),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/jobs'),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: _isLoading
            ? const ShimmerList()
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedWebsiteId,
                          decoration: const InputDecoration(
                            labelText: 'Filter source website',
                            prefixIcon: Icon(Icons.filter_list),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All websites'),
                            ),
                            ..._websites.map(
                              (website) => DropdownMenuItem<String?>(
                                value: website.id,
                                child: Text(website.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedWebsiteId = value);
                          },
                        ),
                      ),
                      Expanded(
                        child: entries.isEmpty
                            ? Center(
                                child: Text(
                                  _selectedWebsiteId == null
                                      ? 'No job applications yet'
                                      : 'No applications for this website',
                                ),
                              )
                            : ListView.builder(
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  final websiteName = _websiteName(entry.websiteId);
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _statusColor(entry.status)
                                            .withValues(alpha: 0.2),
                                        child: Icon(Icons.work,
                                            color: _statusColor(entry.status)),
                                      ),
                                      title: Text(entry.position),
                                      subtitle: Text(
                                        '${entry.companyName} • ${entry.status}${websiteName == null ? '' : ' • $websiteName'}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (entry.isFavorite)
                                            const Icon(Icons.star,
                                                color: Colors.amber),
                                          if (entry.url != null &&
                                              entry.url!.isNotEmpty)
                                            IconButton(
                                              tooltip: 'Open posting',
                                              icon: const Icon(Icons.open_in_new),
                                              onPressed: () => _openUrl(entry.url!),
                                            ),
                                          IconButton(
                                            tooltip: 'Interviews',
                                            icon: const Icon(Icons.event_note),
                                            onPressed: () => context.go(
                                                '/jobs/interviews',
                                                extra: entry),
                                          ),
                                          IconButton(
                                            tooltip: 'Contacts',
                                            icon: const Icon(Icons.people_outline),
                                            onPressed: () => context.go(
                                                '/jobs/contacts',
                                                extra: entry),
                                          ),
                                        ],
                                      ),
                                      onTap: () =>
                                          context.go('/jobs/edit', extra: entry),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/jobs/new'),
        backgroundColor: AppColors.jobs,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }
}
