import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/bookmark.dart';
import '../../widgets/app_drawer.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Bookmark> _entries = [];
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
      final response = await ApiService().get(ApiConstants.bookmarksUrl);
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _entries = data.map((e) => Bookmark.fromJson(e)).toList();
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
        title: const Text('Bookmark Manager'),
        actions: [
          IconButton(
            tooltip: 'Collections',
            icon: const Icon(Icons.folder_outlined),
            onPressed: () => context.go('/bookmarks/collections'),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/bookmarks'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
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
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _entries.isEmpty
                          ? const Center(child: Text('No bookmarks yet'))
                          : _buildBookmarkList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/bookmarks/new'),
        backgroundColor: AppColors.bookmarks,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookmarkList() {
    final filtered = _searchQuery.isEmpty
        ? _entries
        : _entries.where((e) {
            final q = _searchQuery.toLowerCase();
            return e.title.toLowerCase().contains(q) ||
                e.url.toLowerCase().contains(q);
          }).toList();

    if (filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No matching bookmarks')),
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
              backgroundColor: AppColors.bookmarks.withValues(alpha: 0.2),
              child: const Icon(Icons.bookmark, color: AppColors.bookmarks),
            ),
            title: Text(entry.title),
            subtitle: Text(
              entry.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.isFavorite)
                  const Icon(Icons.star, color: Colors.amber),
                IconButton(
                  tooltip: 'Open link',
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _openUrl(entry.url),
                ),
              ],
            ),
            onTap: () => context.go('/bookmarks/edit', extra: entry),
          ),
        );
      },
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
