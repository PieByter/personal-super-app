import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/budget.dart';

class BudgetFormScreen extends StatefulWidget {
  final Budget? budget;
  const BudgetFormScreen({super.key, this.budget});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _amountController = TextEditingController();
  final _thresholdController = TextEditingController();
  String _period = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    if (b != null) {
      _amountController.text = b.amount;
      _thresholdController.text = b.alertThreshold ?? '80';
      _period = b.period;
      _startDate = DateTime.tryParse(b.startDate) ?? DateTime.now();
      _endDate = b.endDate != null ? DateTime.tryParse(b.endDate!) : null;
    }
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? _startDate) : _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isEnd) {
          _endDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'amount': _amountController.text,
      'period': _period,
      'startDate': _startDate.toIso8601String().split('T')[0],
      'endDate': _endDate?.toIso8601String().split('T')[0],
      'alertThreshold': _thresholdController.text,
    };
    try {
      final b = widget.budget;
      if (b != null) {
        await ApiService().put('${ApiConstants.budgetsUrl}/${b.id}', body);
      } else {
        await ApiService().post(ApiConstants.budgetsUrl, body);
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
    final isEdit = widget.budget != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Budget' : 'Add Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField(
              initialValue: _period,
              decoration: const InputDecoration(labelText: 'Period'),
              items: const [
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _period = v as String),
            ),
            const SizedBox(height: 12),
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
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Alert Threshold (%)',
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isEnd: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End Date'),
              subtitle: Text(_endDate != null
                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isEnd: true),
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
    _thresholdController.dispose();
    super.dispose();
  }
}
