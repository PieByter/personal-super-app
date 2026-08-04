import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';

class ProjectTasksScreen extends StatefulWidget {
  final Project project;
  const ProjectTasksScreen({super.key, required this.project});

  @override
  State<ProjectTasksScreen> createState() => _ProjectTasksScreenState();
}

class _ProjectTasksScreenState extends State<ProjectTasksScreen> {
  List<ProjectTask> _tasks = [];
  bool _isLoading = true;
  String? _error;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'todo';
  String _priority = 'medium';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final response = await ApiService()
          .get('${ApiConstants.projectsUrl}/${widget.project.id}/tasks');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _tasks = data.map((e) => ProjectTask.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) return;
    try {
      await ApiService()
          .post('${ApiConstants.projectsUrl}/${widget.project.id}/tasks', {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'status': _status,
        'priority': _priority,
        'dueDate': _dueDate?.toIso8601String().split('T')[0],
      });
      _titleController.clear();
      _descriptionController.clear();
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Color _statusColor(String status) {
    return switch (status) {
      'done' => Colors.green,
      'in_progress' => Colors.blue,
      'review' => Colors.orange,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.project.name} Tasks')),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Add Task'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'todo', child: Text('To Do')),
                        DropdownMenuItem(
                            value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(
                            value: 'review', child: Text('Review')),
                        DropdownMenuItem(value: 'done', child: Text('Done')),
                      ],
                      onChanged: (v) => setState(() => _status = v as String),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(
                            value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                      ],
                      onChanged: (v) => setState(() => _priority = v as String),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Due Date'),
                      subtitle: Text(_dueDate != null
                          ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                          : 'Optional'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _addTask,
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _tasks.isEmpty
                        ? const Center(child: Text('No tasks yet'))
                        : ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final t = _tasks[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _statusColor(t.status).withValues(alpha: 0.2),
                                    child: Icon(Icons.task,
                                        color: _statusColor(t.status)),
                                  ),
                                  title: Text(t.title),
                                  subtitle: Text(
                                    '${t.status} • ${t.priority}\n${t.dueDate ?? ''}',
                                  ),
                                  isThreeLine: true,
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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
