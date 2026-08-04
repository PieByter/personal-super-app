import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/journal.dart';

class JournalEntryFormScreen extends StatefulWidget {
  final JournalEntry? entry;
  const JournalEntryFormScreen({super.key, this.entry});

  @override
  State<JournalEntryFormScreen> createState() => _JournalEntryFormScreenState();
}

class _JournalEntryFormScreenState extends State<JournalEntryFormScreen> {
  final _titleController = TextEditingController();
  final _problemController = TextEditingController();
  final _rootCauseController = TextEditingController();
  final _solutionController = TextEditingController();
  final _conceptController = TextEditingController();
  final _codeController = TextEditingController();
  final _languageController = TextEditingController();
  final _projectController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _titleController.text = e.title;
      _problemController.text = e.problem ?? '';
      _rootCauseController.text = e.rootCause ?? '';
      _solutionController.text = e.solution ?? '';
      _conceptController.text = e.conceptLearned ?? '';
      _codeController.text = e.codeSnippet ?? '';
      _languageController.text = e.language ?? '';
      _projectController.text = e.projectName ?? '';
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'title': _titleController.text,
      'problem': _problemController.text,
      'rootCause': _rootCauseController.text,
      'solution': _solutionController.text,
      'conceptLearned': _conceptController.text,
      'codeSnippet': _codeController.text,
      'language': _languageController.text,
      'projectName': _projectController.text,
    };
    try {
      final e = widget.entry;
      if (e != null) {
        await ApiService().put('${ApiConstants.journalUrl}/${e.id}', body);
      } else {
        await ApiService().post(ApiConstants.journalUrl, body);
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
    final isEdit = widget.entry != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Entry' : 'Add Journal Entry')),
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
              controller: _projectController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _languageController,
              decoration:
                  const InputDecoration(labelText: 'Language/Framework'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _problemController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Problem'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rootCauseController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Root Cause'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _solutionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Solution'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conceptController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Concept Learned'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Code Snippet',
                alignLabelWithHint: true,
              ),
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
    _problemController.dispose();
    _rootCauseController.dispose();
    _solutionController.dispose();
    _conceptController.dispose();
    _codeController.dispose();
    _languageController.dispose();
    _projectController.dispose();
    super.dispose();
  }
}
