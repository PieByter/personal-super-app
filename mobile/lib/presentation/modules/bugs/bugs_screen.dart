import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/bug.dart';
import '../../widgets/app_drawer.dart';

class BugsScreen extends StatefulWidget {
  const BugsScreen({super.key});

  @override
  State<BugsScreen> createState() => _BugsScreenState();
}

class _BugsScreenState extends State<BugsScreen> {
  List<BugEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final response = await ApiService().get(ApiConstants.bugsUrl);
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _entries = data.map((e) => BugEntry.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _severityColor(String severity) {
    return switch (severity) {
      'critical' => Colors.red.shade700,
      'high' => Colors.red,
      'medium' => Colors.orange,
      _ => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bug Tracker')),
      drawer: const AppDrawer(currentRoute: '/bugs'),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _entries.isEmpty
                    ? const Center(child: Text('No bugs logged yet'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _severityColor(entry.severity)
                                    .withValues(alpha: 0.2),
                                child: Icon(Icons.bug_report,
                                    color: _severityColor(entry.severity)),
                              ),
                              title: Text(entry.title),
                              subtitle: Text(
                                '${entry.status} • ${entry.technology ?? 'Unknown'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Chip(
                                label: Text(entry.severity),
                                backgroundColor: _severityColor(entry.severity)
                                    .withValues(alpha: 0.2),
                                side: BorderSide.none,
                              ),
                              onTap: () =>
                                  context.go('/bugs/edit', extra: entry),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/bugs/new'),
        backgroundColor: AppColors.bugs,
        child: const Icon(Icons.add),
      ),
    );
  }
}
