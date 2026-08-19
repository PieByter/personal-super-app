import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';

class JobStatsScreen extends StatefulWidget {
  const JobStatsScreen({super.key});

  @override
  State<JobStatsScreen> createState() => _JobStatsScreenState();
}

class _JobStatsScreenState extends State<JobStatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await ApiService().get(ApiConstants.jobsStatsUrl);
      setState(() {
        _stats = response as Map<String, dynamic>;
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
      appBar: AppBar(title: const Text('Job Statistics')),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _stats == null
                    ? const Center(child: Text('No data'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildRateCard(
                            'Total Applications',
                            '${_stats!['total'] ?? 0}',
                            Icons.work,
                            AppColors.jobs,
                          ),
                          const SizedBox(height: 12),
                          _buildRateCard(
                            'Response Rate',
                            '${_stats!['responseRate'] ?? 0}%',
                            Icons.reply,
                            AppColors.finance,
                          ),
                          const SizedBox(height: 12),
                          _buildRateCard(
                            'Interview Rate',
                            '${_stats!['interviewRate'] ?? 0}%',
                            Icons.event_note,
                            AppColors.projects,
                          ),
                          const SizedBox(height: 12),
                          _buildRateCard(
                            'Offer Rate',
                            '${_stats!['offerRate'] ?? 0}%',
                            Icons.emoji_events,
                            AppColors.habits,
                          ),
                          const SizedBox(height: 12),
                          _buildRateCard(
                            'Applied (30 days)',
                            '${_stats!['recent30Days'] ?? 0}',
                            Icons.schedule,
                            AppColors.dashboard,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Applications by Status',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._buildStatusList(),
                        ],
                      ),
      ),
    );
  }

  Widget _buildRateCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        subtitle: Text(label),
      ),
    );
  }

  List<Widget> _buildStatusList() {
    final byStatus = _stats!['byStatus'] as Map<String, dynamic>? ?? {};
    if (byStatus.isEmpty) {
      return [
        const Card(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No applications yet')))
      ];
    }
    final total = (_stats!['total'] as num?)?.toDouble() ?? 0;
    return byStatus.entries.map((e) {
      final count = (e.value as num?)?.toDouble() ?? 0;
      final pct = total > 0 ? (count / total) * 100 : 0.0;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(e.key)),
                  Text('${count.toInt()} (${pct.toStringAsFixed(0)}%)'),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.jobs,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
