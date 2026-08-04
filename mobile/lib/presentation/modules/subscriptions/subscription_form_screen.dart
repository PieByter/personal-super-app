import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/subscription.dart';

class SubscriptionFormScreen extends StatefulWidget {
  final Subscription? subscription;
  const SubscriptionFormScreen({super.key, this.subscription});

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'IDR');
  final _paymentMethodController = TextEditingController();
  final _reminderController = TextEditingController(text: '3');
  String _billingCycle = 'monthly';
  DateTime? _nextRenewal;
  DateTime? _startDate;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    if (s != null) {
      _nameController.text = s.name;
      _providerController.text = s.provider ?? '';
      _categoryController.text = s.category ?? '';
      _descriptionController.text = s.description ?? '';
      _amountController.text = s.amount;
      _currencyController.text = s.currency;
      _paymentMethodController.text = s.paymentMethod ?? '';
      _reminderController.text = s.reminderDays?.toString() ?? '3';
      _billingCycle = s.billingCycle;
      _nextRenewal = s.nextRenewalDate != null
          ? DateTime.tryParse(s.nextRenewalDate!)
          : null;
      _startDate = s.startDate != null ? DateTime.tryParse(s.startDate!) : null;
      _isActive = s.isActive;
    }
  }

  Future<void> _pickDate({required bool isRenewal}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isRenewal
          ? (_nextRenewal ?? DateTime.now())
          : (_startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isRenewal) {
          _nextRenewal = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'provider': _providerController.text,
      'category': _categoryController.text,
      'description': _descriptionController.text,
      'amount': _amountController.text,
      'currency': _currencyController.text,
      'billingCycle': _billingCycle,
      'nextRenewalDate': _nextRenewal?.toIso8601String().split('T')[0],
      'startDate': _startDate?.toIso8601String().split('T')[0],
      'paymentMethod': _paymentMethodController.text,
      'reminderDays': int.tryParse(_reminderController.text),
      'isActive': _isActive,
    };
    try {
      final s = widget.subscription;
      if (s != null) {
        await ApiService()
            .put('${ApiConstants.subscriptionsUrl}/${s.id}', body);
      } else {
        await ApiService().post(ApiConstants.subscriptionsUrl, body);
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
    final isEdit = widget.subscription != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Edit Subscription' : 'Add Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _providerController,
              decoration: const InputDecoration(labelText: 'Provider'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'Rp ',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _currencyController,
                    decoration: const InputDecoration(labelText: 'Currency'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _billingCycle,
              decoration: const InputDecoration(labelText: 'Billing Cycle'),
              items: const [
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                DropdownMenuItem(value: 'lifetime', child: Text('Lifetime')),
              ],
              onChanged: (v) => setState(() => _billingCycle = v as String),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(_startDate != null
                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isRenewal: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Next Renewal'),
              subtitle: Text(_nextRenewal != null
                  ? DateFormat('yyyy-MM-dd').format(_nextRenewal!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isRenewal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(labelText: 'Payment Method'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reminderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reminder Days',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
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
    _nameController.dispose();
    _providerController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _paymentMethodController.dispose();
    _reminderController.dispose();
    super.dispose();
  }
}
