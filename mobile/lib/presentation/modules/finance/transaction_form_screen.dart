import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/transaction.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _paymentController = TextEditingController();
  String _type = 'expense';
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _amountController.text = t.amount;
      _descController.text = t.description ?? '';
      _paymentController.text = t.paymentMethod ?? '';
      _type = t.type;
      _date = DateTime.tryParse(t.transactionDate) ?? DateTime.now();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'amount': _amountController.text,
      'type': _type,
      'description': _descController.text,
      'paymentMethod': _paymentController.text,
      'transactionDate': _date.toIso8601String().split('T')[0],
    };
    try {
      final t = widget.transaction;
      if (t != null) {
        await ApiService().put(
          '${ApiConstants.transactionsUrl}/${t.id}',
          body,
        );
      } else {
        await ApiService().post(ApiConstants.transactionsUrl, body);
      }
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
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
            const SizedBox(height: 12),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(labelText: 'Payment Method'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _paymentController.dispose();
    super.dispose();
  }
}
