import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/daily_metric.dart';

class DailyMetricsScreen extends StatefulWidget {
  const DailyMetricsScreen({super.key});

  @override
  State<DailyMetricsScreen> createState() => _DailyMetricsScreenState();
}

class _DailyMetricsScreenState extends State<DailyMetricsScreen> {
  DailyMetric? _metric;
  bool _isLoading = true;
  DateTime _date = DateTime.now();
  final _sleepController = TextEditingController();
  final _studyController = TextEditingController();
  final _codingController = TextEditingController();
  final _deepWorkController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _readingController = TextEditingController();
  final _screenTimeController = TextEditingController();
  final _moodController = TextEditingController();
  final _energyController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMetric();
  }

  Future<void> _loadMetric() async {
    try {
      final response = await ApiService().get(
          '${ApiConstants.habitsUrl}/metrics?date=${_date.toIso8601String().split('T')[0]}');
      setState(() {
        if (response != null && response is Map) {
          _metric = DailyMetric.fromJson(response as Map<String, dynamic>);
          _populate(_metric!);
        } else {
          _metric = null;
          _clear();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _populate(DailyMetric m) {
    _sleepController.text = m.sleepHours ?? '';
    _studyController.text = m.studyHours ?? '';
    _codingController.text = m.codingHours ?? '';
    _deepWorkController.text = m.deepWorkHours ?? '';
    _exerciseController.text = m.exerciseMinutes?.toString() ?? '';
    _readingController.text = m.readingMinutes?.toString() ?? '';
    _screenTimeController.text = m.screenTimeMinutes?.toString() ?? '';
    _moodController.text = m.mood?.toString() ?? '';
    _energyController.text = m.energyLevel?.toString() ?? '';
    _notesController.text = m.notes ?? '';
  }

  void _clear() {
    _sleepController.clear();
    _studyController.clear();
    _codingController.clear();
    _deepWorkController.clear();
    _exerciseController.clear();
    _readingController.clear();
    _screenTimeController.clear();
    _moodController.clear();
    _energyController.clear();
    _notesController.clear();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _isLoading = true;
      });
      _loadMetric();
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final body = {
      'metricDate': _date.toIso8601String().split('T')[0],
      'sleepHours': _sleepController.text,
      'studyHours': _studyController.text,
      'codingHours': _codingController.text,
      'deepWorkHours': _deepWorkController.text,
      'exerciseMinutes': int.tryParse(_exerciseController.text),
      'readingMinutes': int.tryParse(_readingController.text),
      'screenTimeMinutes': int.tryParse(_screenTimeController.text),
      'mood': int.tryParse(_moodController.text),
      'energyLevel': int.tryParse(_energyController.text),
      'notes': _notesController.text,
    };
    try {
      if (_metric != null) {
        await ApiService()
            .put('${ApiConstants.habitsUrl}/metrics/${_metric!.id}', body);
      } else {
        await ApiService().post('${ApiConstants.habitsUrl}/metrics', body);
      }
      _loadMetric();
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
      appBar: AppBar(
        title: const Text('Daily Metrics'),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(_date),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sleepController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Sleep (h)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _studyController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Study (h)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codingController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Coding (h)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _deepWorkController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Deep Work (h)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _exerciseController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Exercise (min)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _readingController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Reading (min)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _screenTimeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Screen Time (min)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _moodController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Mood (1-10)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _energyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Energy (1-10)',
                          ),
                        ),
                      ),
                    ],
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
                      onPressed: _save,
                      child: const Text('Save Metrics'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _sleepController.dispose();
    _studyController.dispose();
    _codingController.dispose();
    _deepWorkController.dispose();
    _exerciseController.dispose();
    _readingController.dispose();
    _screenTimeController.dispose();
    _moodController.dispose();
    _energyController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
