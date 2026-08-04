import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/bug.dart';

class BugFormScreen extends StatefulWidget {
  final BugEntry? bug;
  const BugFormScreen({super.key, this.bug});

  @override
  State<BugFormScreen> createState() => _BugFormScreenState();
}

class _BugFormScreenState extends State<BugFormScreen> {
  final _titleController = TextEditingController();
  final _projectController = TextEditingController();
  final _techController = TextEditingController();
  final _errorMessageController = TextEditingController();
  final _errorTypeController = TextEditingController();
  final _causeController = TextEditingController();
  final _solutionController = TextEditingController();
  String _status = 'open';
  String _severity = 'medium';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bug;
    if (b != null) {
      _titleController.text = b.title;
      _projectController.text = b.projectName ?? '';
      _techController.text = b.technology ?? '';
      _errorMessageController.text = b.errorMessage ?? '';
      _errorTypeController.text = b.errorType ?? '';
      _causeController.text = b.cause ?? '';
      _solutionController.text = b.solution ?? '';
      _status = b.status;
      _severity = b.severity;
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'title': _titleController.text,
      'projectName': _projectController.text,
      'technology': _techController.text,
      'errorMessage': _errorMessageController.text,
      'errorType': _errorTypeController.text,
      'cause': _causeController.text,
      'solution': _solutionController.text,
      'status': _status,
      'severity': _severity,
    };
    try {
      final b = widget.bug;
      if (b != null) {
        await ApiService().put('${ApiConstants.bugsUrl}/${b.id}', body);
      } else {
        await ApiService().post(ApiConstants.bugsUrl, body);
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
    final isEdit = widget.bug != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Bug' : 'Add Bug')),
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
              controller: _techController,
              decoration: const InputDecoration(labelText: 'Technology'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _severity,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
              ],
              onChanged: (v) => setState(() => _severity = v as String),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'open', child: Text('Open')),
                DropdownMenuItem(
                    value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'solved', child: Text('Solved')),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
              onChanged: (v) => setState(() => _status = v as String),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _errorMessageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Error Message'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _errorTypeController,
              decoration: const InputDecoration(labelText: 'Error Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _causeController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Cause'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _solutionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Solution'),
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
    _projectController.dispose();
    _techController.dispose();
    _errorMessageController.dispose();
    _errorTypeController.dispose();
    _causeController.dispose();
    _solutionController.dispose();
    super.dispose();
  }
}
