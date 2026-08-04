import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/interview.dart';
import '../../../domain/models/job.dart';

class JobInterviewsScreen extends StatefulWidget {
  final JobApplication job;
  const JobInterviewsScreen({super.key, required this.job});

  @override
  State<JobInterviewsScreen> createState() => _JobInterviewsScreenState();
}

class _JobInterviewsScreenState extends State<JobInterviewsScreen> {
  List<Interview> _interviews = [];
  bool _isLoading = true;
  String? _error;
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  final _interviewerNameController = TextEditingController();
  final _interviewerEmailController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _scheduledAt = DateTime.now();
  final int _duration = 60;
  final int _round = 1;

  @override
  void initState() {
    super.initState();
    _loadInterviews();
  }

  Future<void> _loadInterviews() async {
    try {
      final response = await ApiService()
          .get('${ApiConstants.jobsUrl}/${widget.job.id}/interviews');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _interviews = data.map((e) => Interview.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addInterview() async {
    if (_typeController.text.isEmpty) return;
    try {
      await ApiService()
          .post('${ApiConstants.jobsUrl}/${widget.job.id}/interviews', {
        'round': _round,
        'interviewType': _typeController.text,
        'scheduledAt': _scheduledAt.toIso8601String(),
        'durationMinutes': _duration,
        'location': _locationController.text,
        'meetingUrl': _urlController.text,
        'interviewerName': _interviewerNameController.text,
        'interviewerEmail': _interviewerEmailController.text,
        'notes': _notesController.text,
      });
      _typeController.clear();
      _locationController.clear();
      _urlController.clear();
      _interviewerNameController.clear();
      _interviewerEmailController.clear();
      _notesController.clear();
      _loadInterviews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    // ignore: use_build_context_synchronously
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    if (!mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.job.companyName} Interviews'),
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Schedule Interview'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Interview Type',
                        hintText: 'HR, Technical, Final',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Scheduled At'),
                      subtitle: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(_scheduledAt)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDateTime,
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration:
                          const InputDecoration(labelText: 'Meeting URL'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _interviewerNameController,
                      decoration:
                          const InputDecoration(labelText: 'Interviewer Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _interviewerEmailController,
                      decoration:
                          const InputDecoration(labelText: 'Interviewer Email'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _addInterview,
                      child: const Text('Schedule'),
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
                    : _interviews.isEmpty
                        ? const Center(child: Text('No interviews yet'))
                        : ListView.builder(
                            itemCount: _interviews.length,
                            itemBuilder: (context, index) {
                              final i = _interviews[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.jobs.withValues(alpha: 0.2),
                                    child: const Icon(Icons.event,
                                        color: AppColors.jobs),
                                  ),
                                  title: Text(
                                      'Round ${i.round} - ${i.interviewType}'),
                                  subtitle: Text(
                                    '${i.scheduledAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(i.scheduledAt!) : 'TBD'}\n${i.location ?? ''}',
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
    _typeController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    _interviewerNameController.dispose();
    _interviewerEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
