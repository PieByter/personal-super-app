import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/habit.dart';
import '../../widgets/app_drawer.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final response = await ApiService().get(ApiConstants.habitsUrl);
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _entries = data.map((e) => Habit.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      drawer: const AppDrawer(currentRoute: '/habits'),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _entries.isEmpty
                    ? const Center(child: Text('No habits yet'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.habits.withValues(alpha: 0.2),
                                child: const Icon(Icons.check_circle,
                                    color: AppColors.habits),
                              ),
                              title: Text(entry.name),
                              subtitle: Text(
                                '${entry.frequency} • ${entry.targetValue ?? "1"} ${entry.unit ?? ""}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: entry.isActive
                                  ? const Icon(Icons.notifications_active,
                                      color: Colors.green)
                                  : const Icon(Icons.notifications_off,
                                      color: Colors.grey),
                              onTap: () =>
                                  context.go('/habits/edit', extra: entry),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/habits/new'),
        backgroundColor: AppColors.habits,
        child: const Icon(Icons.add),
      ),
    );
  }
}
