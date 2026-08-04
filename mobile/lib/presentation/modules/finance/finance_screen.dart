import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/transaction.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final response = await ApiService().get(ApiConstants.transactionsUrl);
      setState(() {
        _transactions = (response['data'] as List)
            .map((e) => Transaction.fromJson(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
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
    return const Center(child: Text('Budgets - Coming Soon'));
  }

  Widget _buildGoalsTab() {
    return const Center(child: Text('Saving Goals - Coming Soon'));
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
