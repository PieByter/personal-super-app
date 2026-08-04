import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/job.dart';
import '../../widgets/app_drawer.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  List<JobApplication> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final response = await ApiService().get(ApiConstants.jobsUrl);
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _entries = data.map((e) => JobApplication.fromJson(e)).toList();
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
      'offer' || 'accepted' => Colors.green,
      'interview' || 'technical_test' => Colors.blue,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Tracker')),
      drawer: const AppDrawer(currentRoute: '/jobs'),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _entries.isEmpty
                    ? const Center(child: Text('No job applications yet'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _statusColor(entry.status).withValues(alpha: 0.2),
                                child: Icon(Icons.work,
                                    color: _statusColor(entry.status)),
                              ),
                              title: Text(entry.position),
                              subtitle: Text(
                                '${entry.companyName} • ${entry.status}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: entry.isFavorite
                                  ? const Icon(Icons.star, color: Colors.amber)
                                  : null,
                              onTap: () {},
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.jobs,
        child: const Icon(Icons.add),
      ),
    );
  }
}
