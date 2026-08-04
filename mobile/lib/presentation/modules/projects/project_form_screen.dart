import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/project.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  final _progressController = TextEditingController();
  final _techStackController = TextEditingController();
  final _gitController = TextEditingController();
  final _docsController = TextEditingController();
  final _colorController = TextEditingController();
  String _status = 'active';
  String _priority = 'medium';
  DateTime? _startDate;
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    if (p != null) {
      _nameController.text = p.name;
      _descriptionController.text = p.description ?? '';
      _goalController.text = p.goal ?? '';
      _progressController.text = p.progress ?? '';
      _techStackController.text = p.techStack?.join(', ') ?? '';
      _gitController.text = p.gitRepository ?? '';
      _docsController.text = p.documentationUrl ?? '';
      _colorController.text = p.color;
      _status = p.status;
      _priority = p.priority;
      _startDate = p.startDate != null ? DateTime.tryParse(p.startDate!) : null;
      _targetDate =
          p.targetDate != null ? DateTime.tryParse(p.targetDate!) : null;
    }
  }

  Future<void> _pickDate({required bool isTarget}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isTarget
          ? (_targetDate ?? DateTime.now())
          : (_startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isTarget) {
          _targetDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'goal': _goalController.text,
      'status': _status,
      'priority': _priority,
      'progress': _progressController.text,
      'startDate': _startDate?.toIso8601String().split('T')[0],
      'targetDate': _targetDate?.toIso8601String().split('T')[0],
      'techStack': _techStackController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'gitRepository': _gitController.text,
      'documentationUrl': _docsController.text,
      'color': _colorController.text,
    };
    try {
      final p = widget.project;
      if (p != null) {
        await ApiService().put('${ApiConstants.projectsUrl}/${p.id}', body);
      } else {
        await ApiService().post(ApiConstants.projectsUrl, body);
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
    final isEdit = widget.project != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Project' : 'Add Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Goal'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (v) => setState(() => _status = v as String),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (v) => setState(() => _priority = v as String),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _progressController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Progress (%)',
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(_startDate != null
                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isTarget: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Target Date'),
              subtitle: Text(_targetDate != null
                  ? DateFormat('yyyy-MM-dd').format(_targetDate!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isTarget: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _techStackController,
              decoration: const InputDecoration(
                labelText: 'Tech Stack',
                hintText: 'Comma separated',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gitController,
              decoration: const InputDecoration(labelText: 'Git Repository'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _docsController,
              decoration: const InputDecoration(labelText: 'Documentation URL'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color Hex'),
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
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    _progressController.dispose();
    _techStackController.dispose();
    _gitController.dispose();
    _docsController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
