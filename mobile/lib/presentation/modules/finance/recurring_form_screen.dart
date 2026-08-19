import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/recurring_rule.dart';

class RecurringFormScreen extends StatefulWidget {
  final RecurringRule? rule;
  const RecurringFormScreen({super.key, this.rule});

  @override
  State<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends State<RecurringFormScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _type = 'expense';
  String _frequency = 'monthly';
  int _interval = 1;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    if (r != null) {
      _amountController.text = r.amount;
      _descController.text = r.description ?? '';
      _type = r.type;
      _frequency = r.frequency;
      _interval = r.interval;
      _startDate = DateTime.tryParse(r.startDate) ?? DateTime.now();
      _endDate = r.endDate != null ? DateTime.tryParse(r.endDate!) : null;
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
      'type': _type,
      'frequency': _frequency,
      'interval': _interval,
      'startDate': _startDate.toIso8601String().split('T')[0],
      'endDate': _endDate?.toIso8601String().split('T')[0],
      'description': _descController.text,
    };
    try {
      final r = widget.rule;
      if (r != null) {
        await ApiService().put('${ApiConstants.recurringUrl}/${r.id}', body);
      } else {
        await ApiService().post(ApiConstants.recurringUrl, body);
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
    final isEdit = widget.rule != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Recurring' : 'Add Recurring')),
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
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _frequency = v as String),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                      'Every $_interval ${_frequency == 'daily' ? 'day(s)' : _frequency == 'weekly' ? 'week(s)' : _frequency == 'monthly' ? 'month(s)' : 'year(s)'}'),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      _interval > 1 ? () => setState(() => _interval--) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _interval++),
                ),
              ],
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
    _descController.dispose();
    super.dispose();
  }
}
