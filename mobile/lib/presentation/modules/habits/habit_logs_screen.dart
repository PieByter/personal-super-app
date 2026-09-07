import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_log.dart';

class HabitLogsScreen extends StatefulWidget {
  final Habit habit;
  const HabitLogsScreen({super.key, required this.habit});

  @override
  State<HabitLogsScreen> createState() => _HabitLogsScreenState();
}

class _HabitLogsScreenState extends State<HabitLogsScreen> {
  List<HabitLog> _logs = [];
  bool _isLoading = true;
  String? _error;
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  final _moodController = TextEditingController();
  DateTime _logDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _valueController.text = widget.habit.targetValue ?? '1';
    _loadLogs();
  }

  /// Dates that have at least one log, for calendar markers.
  Set<DateTime> get _loggedDates => _logs
      .map((l) => DateTime.tryParse(l.logDate))
      .whereType<DateTime>()
      .toSet();

  /// Logs filtered by the selected calendar day (null = all).
  List<HabitLog> get _visibleLogs {
    if (_selectedDay == null) return _logs;
    final day = _selectedDay!;
    return _logs.where((l) {
      final d = DateTime.tryParse(l.logDate);
      return d != null &&
          d.year == day.year &&
          d.month == day.month &&
          d.day == day.day;
    }).toList();
  }

  Future<void> _loadLogs() async {
    try {
      final response = await ApiService()
          .get('${ApiConstants.habitsUrl}/${widget.habit.id}/logs');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _logs = data.map((e) => HabitLog.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addLog() async {
    try {
      await ApiService()
          .post('${ApiConstants.habitsUrl}/${widget.habit.id}/logs', {
        'logDate': _logDate.toIso8601String().split('T')[0],
        'value': _valueController.text,
        'notes': _notesController.text,
        'mood': _moodController.text,
      });
      _notesController.clear();
      _moodController.clear();
      _loadLogs();
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
      initialDate: _logDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _logDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.habit.name} Logs')),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Add Log'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Log Date'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(_logDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    TextField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Value (${widget.habit.unit ?? 'count'})',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _moodController,
                      decoration: const InputDecoration(labelText: 'Mood'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _addLog,
                      child: const Text('Add Log'),
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
                    : Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8),
                            child: TableCalendar(
                              firstDay: DateTime(2000),
                              lastDay: DateTime.now(),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(day, _selectedDay),
                              eventLoader: (day) =>
                                  _loggedDates.contains(day) ? [day] : [],
                              onDaySelected: (selected, focused) {
                                setState(() {
                                  _selectedDay = selected;
                                  _focusedDay = focused;
                                });
                              },
                              onPageChanged: (focused) => _focusedDay = focused,
                              calendarStyle: CalendarStyle(
                                markerDecoration: const BoxDecoration(
                                  color: AppColors.habits,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppColors.habits.withValues(
                                    alpha: 0.3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: AppColors.habits,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDay != null)
                            ListTile(
                              title: Text(
                                'Logs for ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                              ),
                              trailing: TextButton(
                                onPressed: () =>
                                    setState(() => _selectedDay = null),
                                child: const Text('Show all'),
                              ),
                            ),
                          Expanded(
                            child: _visibleLogs.isEmpty
                                ? const Center(
                                    child: Text('No logs for this day'),
                                  )
                                : ListView.builder(
                                    itemCount: _visibleLogs.length,
                                    itemBuilder: (context, index) {
                                      final l = _visibleLogs[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.habits
                                                .withValues(alpha: 0.2),
                                            child: const Icon(
                                                Icons.check_circle,
                                                color: AppColors.habits),
                                          ),
                                          title: Text(
                                              '${l.value} ${widget.habit.unit ?? ''}'),
                                          subtitle: Text(
                                            '${l.logDate}\n${l.mood ?? ''} ${l.notes ?? ''}',
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    _moodController.dispose();
    super.dispose();
  }
}
