import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';

class HabitStatsScreen extends StatefulWidget {
  const HabitStatsScreen({super.key});

  @override
  State<HabitStatsScreen> createState() => _HabitStatsScreenState();
}

class _HabitStatsScreenState extends State<HabitStatsScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ApiService().get(ApiConstants.habitsStatsUrl);
      setState(() {
        _items = response as List;
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
      appBar: AppBar(title: const Text('Habit Streaks')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _items.isEmpty
                    ? const Center(child: Text('No habits yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index] as Map<String, dynamic>;
                          final current =
                              (item['currentStreak'] as num?)?.toInt() ?? 0;
                          final longest =
                              (item['longestStreak'] as num?)?.toInt() ?? 0;
                          final total =
                              (item['totalLogs'] as num?)?.toInt() ?? 0;
                          final last90 = (item['last90Days'] as List?) ?? [];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'] as String? ?? 'Habit',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.habits
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '🔥 $current day streak',
                                          style: const TextStyle(
                                            color: AppColors.habits,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildMiniStat(
                                          'Longest', '$longest days'),
                                      _buildMiniStat('Total logs', '$total'),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildHeatmap(last90),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Simple 90-day heatmap: a wrap of small squares, colored if logged.
  Widget _buildHeatmap(List<dynamic> loggedDates) {
    final logged = loggedDates.map((d) => d.toString()).toSet();
    final today = DateTime.now();
    final days = <DateTime>[];
    for (var i = 89; i >= 0; i--) {
      days.add(today.subtract(Duration(days: i)));
    }
    String toStr(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: days.map((d) {
        final loggedDay = logged.contains(toStr(d));
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: loggedDay ? AppColors.habits : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}
