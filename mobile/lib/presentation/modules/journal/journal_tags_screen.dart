import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/journal_tag.dart';

class JournalTagsScreen extends StatefulWidget {
  const JournalTagsScreen({super.key});

  @override
  State<JournalTagsScreen> createState() => _JournalTagsScreenState();
}

class _JournalTagsScreenState extends State<JournalTagsScreen> {
  List<JournalTag> _tags = [];
  bool _isLoading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _colorController = TextEditingController(text: '#6366F1');

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final response =
          await ApiService().get('${ApiConstants.journalUrl}/tags');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _tags = data.map((e) => JournalTag.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTag() async {
    if (_nameController.text.isEmpty) return;
    try {
      await ApiService().post('${ApiConstants.journalUrl}/tags', {
        'name': _nameController.text,
        'color': _colorController.text,
      });
      _nameController.clear();
      _loadTags();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteTag(String id) async {
    try {
      await ApiService().delete('${ApiConstants.journalUrl}/tags/$id');
      _loadTags();
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
      appBar: AppBar(title: const Text('Journal Tags')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tag Name'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _colorController,
                    decoration: const InputDecoration(labelText: 'Color'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  color: AppColors.journal,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _tags.isEmpty
                        ? const Center(child: Text('No tags yet'))
                        : ListView.builder(
                            itemCount: _tags.length,
                            itemBuilder: (context, index) {
                              final tag = _tags[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(
                                    int.parse(
                                        tag.color.replaceFirst('#', '0xFF')),
                                  ),
                                ),
                                title: Text(tag.name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteTag(tag.id),
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
    _colorController.dispose();
    super.dispose();
  }
}
