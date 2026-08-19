import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/journal.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/shimmer_list.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final response = await ApiService().get(ApiConstants.journalUrl);
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _entries = data.map((e) => JournalEntry.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Journal'),
        actions: [
          IconButton(
            tooltip: 'Tags',
            icon: const Icon(Icons.label_outline),
            onPressed: () => context.go('/journal/tags'),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/journal'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search journal...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEntries,
              child: _isLoading
                  ? const ShimmerList()
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _entries.isEmpty
                          ? const Center(
                              child: Text('No journal entries yet'),
                            )
                          : _buildJournalList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/journal/new'),
        backgroundColor: AppColors.journal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalList() {
    final filtered = _searchQuery.isEmpty
        ? _entries
        : _entries.where((e) {
            final q = _searchQuery.toLowerCase();
            return (e.title.toLowerCase().contains(q)) ||
                (e.projectName?.toLowerCase().contains(q) ?? false);
          }).toList();

    if (filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No matching entries')),
        ],
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.journal.withValues(alpha: 0.2),
              child: const Icon(Icons.edit_note, color: AppColors.journal),
            ),
            title: Text(entry.title),
            subtitle: Text(
              entry.projectName ?? 'No project',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: entry.isFavorite
                ? const Icon(Icons.star, color: Colors.amber)
                : null,
            onTap: () => context.go('/journal/edit', extra: entry),
          ),
        );
      },
    );
  }
}
