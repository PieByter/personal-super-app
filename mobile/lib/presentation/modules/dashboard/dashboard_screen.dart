import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/dashboard.dart';
import '../../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final response = await ApiService().get(ApiConstants.dashboardUrl);
      setState(() {
        _data = DashboardData.fromJson(response);
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
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Error: $_error'))
            : _data == null
            ? const Center(child: Text('No data'))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Overview'),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Finance This Month'),
                    const SizedBox(height: 12),
                    _buildFinanceCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Active Habits (7 days)'),
                    const SizedBox(height: 12),
                    _buildHabitsList(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Quick Access'),
                    const SizedBox(height: 12),
                    _buildQuickAccessGrid(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _Stat(
        'Projects',
        _data!.projects.active.toString(),
        AppColors.projects,
        '/projects',
      ),
      _Stat(
        'Tasks',
        _data!.tasks.todo.toString(),
        AppColors.dashboard,
        '/projects',
      ),
      _Stat('Jobs', _data!.jobs.interview.toString(), AppColors.jobs, '/jobs'),
      _Stat('Bugs', _data!.bugs.open.toString(), AppColors.bugs, '/bugs'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: stats.map((s) => _buildStatCard(s)).toList(),
    );
  }

  Widget _buildStatCard(_Stat stat) {
    return Card(
      child: InkWell(
        onTap: () => context.go(stat.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat.value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: stat.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_data!.finance.monthIncome}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.finance,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_data!.finance.monthExpense}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.bugs,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList() {
    if (_data!.habits.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No habits tracked this week')),
        ),
      );
    }

    return Column(
      children: _data!.habits.map((h) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.habits.withOpacity(0.2),
              child: const Icon(Icons.check, color: AppColors.habits),
            ),
            title: Text(h.habitName),
            subtitle: Text('${h.completedDays} days completed'),
            trailing: Text(
              '${h.completedDays}/7',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      _QuickItem(
        'Add Transaction',
        Icons.add_card,
        AppColors.finance,
        '/finance',
      ),
      _QuickItem('New Journal', Icons.edit_note, AppColors.journal, '/journal'),
      _QuickItem('Log Bug', Icons.bug_report, AppColors.bugs, '/bugs'),
      _QuickItem('Add Job', Icons.work, AppColors.jobs, '/jobs'),
      _QuickItem('New Task', Icons.task_alt, AppColors.projects, '/projects'),
      _QuickItem('Log Habit', Icons.check_circle, AppColors.habits, '/habits'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: items.map((item) => _buildQuickAccessItem(item)).toList(),
    );
  }

  Widget _buildQuickAccessItem(_QuickItem item) {
    return Card(
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 32),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final Color color;
  final String route;
  _Stat(this.label, this.value, this.color, this.route);
}

class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _QuickItem(this.label, this.icon, this.color, this.route);
}
