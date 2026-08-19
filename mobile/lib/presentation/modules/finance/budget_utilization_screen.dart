import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';

class BudgetUtilizationScreen extends StatefulWidget {
  const BudgetUtilizationScreen({super.key});

  @override
  State<BudgetUtilizationScreen> createState() =>
      _BudgetUtilizationScreenState();
}

class _BudgetUtilizationScreenState extends State<BudgetUtilizationScreen> {
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
      final response =
          await ApiService().get(ApiConstants.budgetUtilizationUrl);
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

  Color _statusColor(String status) {
    return switch (status) {
      'exceeded' => Colors.red,
      'warning' => Colors.orange,
      _ => AppColors.finance,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Utilization')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _items.isEmpty
                    ? const Center(child: Text('No active budgets'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index] as Map<String, dynamic>;
                          final status = item['status'] as String? ?? 'ok';
                          final color = _statusColor(status);
                          final utilization =
                              (item['utilization'] as num?)?.toDouble() ?? 0;
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
                                          item['categoryName'] as String? ??
                                              'General',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rp ${item['spent']} / Rp ${item['amount']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value:
                                          (utilization / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade200,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${utilization.toStringAsFixed(0)}% used',
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
