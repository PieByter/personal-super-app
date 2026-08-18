import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/transaction.dart';
import '../../../domain/models/budget.dart';
import '../../../domain/models/goal.dart';
import '../../../domain/models/investment.dart';
import '../../widgets/app_drawer.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingGoal> _goals = [];
  List<Investment> _investments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadTransactions(),
      _loadBudgets(),
      _loadGoals(),
      _loadInvestments(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTransactions() async {
    try {
      final response = await ApiService().get(ApiConstants.transactionsUrl);
      if (mounted) {
        setState(() {
          _transactions = (response['data'] as List)
              .map((e) => Transaction.fromJson(e))
              .toList();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadBudgets() async {
    try {
      final response = await ApiService().get(ApiConstants.budgetsUrl);
      if (mounted) {
        setState(() {
          _budgets = (response as List).map((e) => Budget.fromJson(e)).toList();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadGoals() async {
    try {
      final response = await ApiService().get(ApiConstants.goalsUrl);
      if (mounted) {
        setState(() {
          _goals =
              (response as List).map((e) => SavingGoal.fromJson(e)).toList();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadInvestments() async {
    try {
      final response = await ApiService().get(ApiConstants.investmentsUrl);
      if (mounted) {
        setState(() {
          _investments =
              (response as List).map((e) => Investment.fromJson(e)).toList();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _delete(String url) async {
    try {
      await ApiService().delete(url);
      await _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _confirmDelete({
    required String title,
    required String url,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _delete(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Budgets', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Goals', icon: Icon(Icons.savings)),
            Tab(text: 'Investments', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/finance'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(),
          _buildBudgetsTab(),
          _buildGoalsTab(),
          _buildInvestmentsTab(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    final index = _tabController.index;
    final (label, icon, onPressed) = switch (index) {
      1 => ('Add Budget', Icons.add, () => context.go('/finance/budgets/new')),
      2 => ('Add Goal', Icons.add, () => context.go('/finance/goals/new')),
      3 => (
          'Add Investment',
          Icons.add,
          () => context.go('/finance/investments/new')
        ),
      _ => ('Add', Icons.add, () => _showAddTransactionDialog()),
    };
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildTransactionsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_transactions.isEmpty) {
      return const Center(
        child: Text('No transactions yet. Tap + to add one.'),
      );
    }

    final income = _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + double.parse(t.amount));
    final expense = _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + double.parse(t.amount));

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildMoneyColumn('Income', income, AppColors.finance),
                ),
                Container(height: 50, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: _buildMoneyColumn('Expense', expense, AppColors.bugs),
                ),
                Container(height: 50, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: _buildMoneyColumn(
                    'Balance',
                    income - expense,
                    AppColors.dashboard,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final t = _transactions[index];
              final isIncome = t.type == 'income';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? AppColors.finance.withValues(alpha: 0.2)
                        : AppColors.bugs.withValues(alpha: 0.2),
                    child: Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncome ? AppColors.finance : AppColors.bugs,
                    ),
                  ),
                  title: Text(t.description ?? 'No description'),
                  subtitle: Text(
                    '${t.category?.name ?? 'Uncategorized'} • ${DateFormat('MMM dd').format(DateTime.parse(t.transactionDate))}',
                  ),
                  trailing: Text(
                    '${isIncome ? '+' : '-'} Rp ${NumberFormat('#,###').format(double.parse(t.amount))}',
                    style: TextStyle(
                      color: isIncome ? AppColors.finance : AppColors.bugs,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () =>
                      context.go('/finance/transactions/edit', extra: t),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyColumn(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${NumberFormat('#,###').format(amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBudgetsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_budgets.isEmpty) {
      return const Center(
        child: Text('No budgets yet. Tap + to add one.'),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        itemCount: _budgets.length,
        itemBuilder: (context, index) {
          final b = _budgets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.finance.withValues(alpha: 0.2),
                child: Icon(Icons.pie_chart, color: AppColors.finance),
              ),
              title: Text(
                '${b.period[0].toUpperCase()}${b.period.substring(1)} Budget',
              ),
              subtitle: Text(
                '${DateFormat('MMM yyyy').format(DateTime.parse(b.startDate))}'
                '${b.endDate != null ? ' - ${DateFormat('MMM yyyy').format(DateTime.parse(b.endDate!))}' : ''}'
                ' • ${b.isActive ? 'Active' : 'Inactive'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rp ${NumberFormat('#,###').format(double.parse(b.amount))}',
                    style: const TextStyle(
                      color: AppColors.finance,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(
                      title: '${b.period} budget',
                      url: '${ApiConstants.budgetsUrl}/${b.id}',
                    ),
                  ),
                ],
              ),
              onTap: () => context.go('/finance/budgets/edit', extra: b),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_goals.isEmpty) {
      return const Center(
        child: Text('No saving goals yet. Tap + to add one.'),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final g = _goals[index];
          final target = double.parse(g.targetAmount);
          final current = double.parse(g.currentAmount);
          final progress =
              target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _confirmDelete(
                          title: g.name,
                          url: '${ApiConstants.goalsUrl}/${g.id}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${NumberFormat('#,###').format(current)} / '
                    'Rp ${NumberFormat('#,###').format(target)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.finance,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: AppColors.finance,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (g.deadline != null)
                        Text(
                          'Due ${DateFormat('MMM dd, yyyy').format(DateTime.parse(g.deadline!))}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvestmentsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_investments.isEmpty) {
      return const Center(
        child: Text('No investments yet. Tap + to add one.'),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        itemCount: _investments.length,
        itemBuilder: (context, index) {
          final inv = _investments[index];
          final qty = double.parse(inv.quantity);
          final purchase = double.parse(inv.purchasePrice);
          final current = inv.currentPrice != null
              ? double.parse(inv.currentPrice!)
              : purchase;
          final totalValue = qty * current;
          final totalCost = qty * purchase;
          final profit = totalValue - totalCost;
          final profitPct = totalCost > 0 ? (profit / totalCost) * 100 : 0.0;
          final isProfit = profit >= 0;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.finance.withValues(alpha: 0.2),
                child: Icon(Icons.trending_up, color: AppColors.finance),
              ),
              title: Text(inv.name),
              subtitle: Text(
                '${inv.type}${inv.symbol != null ? ' • ${inv.symbol}' : ''} • '
                '${DateFormat('MMM dd, yyyy').format(DateTime.parse(inv.purchaseDate))}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###').format(totalValue)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${isProfit ? '+' : ''}${profitPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isProfit ? AppColors.finance : AppColors.bugs,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(
                      title: inv.name,
                      url: '${ApiConstants.investmentsUrl}/${inv.id}',
                    ),
                  ),
                ],
              ),
              onTap: () => context.go('/finance/investments/edit', extra: inv),
            ),
          );
        },
      ),
    );
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _type = 'expense';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_amountController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await ApiService().post(ApiConstants.transactionsUrl, {
        'amount': _amountController.text,
        'type': _type,
        'description': _descController.text,
        'transactionDate': DateTime.now().toIso8601String().split('T')[0],
      });
      if (mounted) {
        Navigator.pop(context);
        context.go('/finance');
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Expense'),
                  selected: _type == 'expense',
                  onSelected: (v) => setState(() => _type = 'expense'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Income'),
                  selected: _type == 'income',
                  onSelected: (v) => setState(() => _type = 'income'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Transaction'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
