import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/bookmark_collection.dart';

class BookmarkCollectionsScreen extends StatefulWidget {
  const BookmarkCollectionsScreen({super.key});

  @override
  State<BookmarkCollectionsScreen> createState() =>
      _BookmarkCollectionsScreenState();
}

class _BookmarkCollectionsScreenState extends State<BookmarkCollectionsScreen> {
  List<BookmarkCollection> _collections = [];
  bool _isLoading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController(text: '#EC4899');
  final _iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      final response =
          await ApiService().get('${ApiConstants.bookmarksUrl}/collections');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _collections = data.map((e) => BookmarkCollection.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addCollection() async {
    if (_nameController.text.isEmpty) return;
    try {
      await ApiService().post('${ApiConstants.bookmarksUrl}/collections', {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'color': _colorController.text,
        'icon': _iconController.text,
      });
      _nameController.clear();
      _descriptionController.clear();
      _iconController.clear();
      _loadCollections();
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
      appBar: AppBar(title: const Text('Bookmark Collections')),
      body: Column(
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
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _iconController,
                  decoration: const InputDecoration(labelText: 'Icon'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _addCollection,
                  child: const Text('Add Collection'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _collections.isEmpty
                        ? const Center(child: Text('No collections yet'))
                        : ListView.builder(
                            itemCount: _collections.length,
                            itemBuilder: (context, index) {
                              final c = _collections[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(
                                      int.parse(
                                          c.color.replaceFirst('#', '0xFF')),
                                    ),
                                    child: c.icon != null
                                        ? Icon(
                                            _parseIcon(c.icon!),
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  title: Text(c.name),
                                  subtitle: c.description != null
                                      ? Text(c.description!)
                                      : null,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  IconData _parseIcon(String name) {
    // IconData codePoint must be a compile-time constant; fallback to Icons.folder
    return Icons.folder;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}
