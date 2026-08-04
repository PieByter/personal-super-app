import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/milestone.dart';
import '../../../domain/models/project.dart';

class ProjectMilestonesScreen extends StatefulWidget {
  final Project project;
  const ProjectMilestonesScreen({super.key, required this.project});

  @override
  State<ProjectMilestonesScreen> createState() =>
      _ProjectMilestonesScreenState();
}

class _ProjectMilestonesScreenState extends State<ProjectMilestonesScreen> {
  List<Milestone> _milestones = [];
  bool _isLoading = true;
  String? _error;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    try {
      final response = await ApiService()
          .get('${ApiConstants.projectsUrl}/${widget.project.id}/milestones');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _milestones = data.map((e) => Milestone.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addMilestone() async {
    if (_titleController.text.isEmpty) return;
    try {
      await ApiService()
          .post('${ApiConstants.projectsUrl}/${widget.project.id}/milestones', {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': _dueDate?.toIso8601String().split('T')[0],
      });
      _titleController.clear();
      _descriptionController.clear();
      _loadMilestones();
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

  Future<void> _toggleComplete(Milestone m) async {
    try {
      await ApiService().put(
          '${ApiConstants.projectsUrl}/${widget.project.id}/milestones/${m.id}',
          {
            'isCompleted': !m.isCompleted,
          });
      _loadMilestones();
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
      appBar: AppBar(title: Text('${widget.project.name} Milestones')),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Add Milestone'),
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
                      onPressed: _addMilestone,
                      child: const Text('Add Milestone'),
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
                    : _milestones.isEmpty
                        ? const Center(child: Text('No milestones yet'))
                        : ListView.builder(
                            itemCount: _milestones.length,
                            itemBuilder: (context, index) {
                              final m = _milestones[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: m.isCompleted,
                                    onChanged: (_) => _toggleComplete(m),
                                  ),
                                  title: Text(
                                    m.title,
                                    style: TextStyle(
                                      decoration: m.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${m.dueDate != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(m.dueDate!)) : 'No due date'}\n${m.description ?? ''}',
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
