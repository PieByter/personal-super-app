import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/models/transaction.dart';

/// Pie chart showing expense breakdown by category.
class ExpenseCategoryChart extends StatelessWidget {
  final List<Transaction> transactions;
  const ExpenseCategoryChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Aggregate expenses by category name.
    final Map<String, double> byCategory = {};
    for (final t in transactions) {
      if (t.type != 'expense') continue;
      final name = t.category?.name ?? 'Uncategorized';
      byCategory[name] = (byCategory[name] ?? 0) + double.parse(t.amount);
    }

    if (byCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = byCategory.values.fold(0.0, (a, b) => a + b);
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
    ];

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: colors[i % colors.length],
                        title: total > 0
                            ? '${((entries[i].value / total) * 100).toStringAsFixed(0)}%'
                            : '',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...entries.take(6).map((e) {
              final idx = entries.indexOf(e);
              final pct = total > 0 ? (e.value / total) * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[idx % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
