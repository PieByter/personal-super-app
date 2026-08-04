import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadEntries();
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
      appBar: AppBar(title: const Text('Bookmark Manager')),
      drawer: const AppDrawer(currentRoute: '/bookmarks'),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _entries.isEmpty
                    ? const Center(child: Text('No bookmarks yet'))
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
                                    AppColors.bookmarks.withValues(alpha: 0.2),
                                child: const Icon(Icons.bookmark,
                                    color: AppColors.bookmarks),
                              ),
                              title: Text(entry.title),
                              subtitle: Text(
                                entry.url,
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
        backgroundColor: AppColors.bookmarks,
        child: const Icon(Icons.add),
      ),
    );
  }
}
