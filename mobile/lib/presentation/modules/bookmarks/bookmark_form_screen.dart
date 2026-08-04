import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/bookmark.dart';

class BookmarkFormScreen extends StatefulWidget {
  final Bookmark? bookmark;
  const BookmarkFormScreen({super.key, this.bookmark});

  @override
  State<BookmarkFormScreen> createState() => _BookmarkFormScreenState();
}

class _BookmarkFormScreenState extends State<BookmarkFormScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'unread';
  int? _rating;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bookmark;
    if (b != null) {
      _titleController.text = b.title;
      _urlController.text = b.url;
      _descriptionController.text = b.description ?? '';
      _notesController.text = b.notes ?? '';
      _status = b.status;
      _rating = b.rating;
      _isFavorite = b.isFavorite;
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'title': _titleController.text,
      'url': _urlController.text,
      'description': _descriptionController.text,
      'notes': _notesController.text,
      'status': _status,
      'rating': _rating,
      'isFavorite': _isFavorite,
    };
    try {
      final b = widget.bookmark;
      if (b != null) {
        await ApiService().put('${ApiConstants.bookmarksUrl}/${b.id}', body);
      } else {
        await ApiService().post(ApiConstants.bookmarksUrl, body);
      }
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bookmark != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Bookmark' : 'Add Bookmark')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'unread', child: Text('Unread')),
                DropdownMenuItem(value: 'reading', child: Text('Reading')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'archived', child: Text('Archived')),
              ],
              onChanged: (v) => setState(() => _status = v as String),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _rating,
              decoration: const InputDecoration(labelText: 'Rating'),
              items: [null, 1, 2, 3, 4, 5]
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r == null ? 'No rating' : '$r stars'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Favorite'),
              value: _isFavorite,
              onChanged: (v) => setState(() => _isFavorite = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
