import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/payment.dart';
import '../../../domain/models/subscription.dart';

class SubscriptionPaymentsScreen extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionPaymentsScreen({super.key, required this.subscription});

  @override
  State<SubscriptionPaymentsScreen> createState() =>
      _SubscriptionPaymentsScreenState();
}

class _SubscriptionPaymentsScreenState
    extends State<SubscriptionPaymentsScreen> {
  List<SubscriptionPayment> _payments = [];
  bool _isLoading = true;
  String? _error;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.subscription.amount;
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final response = await ApiService().get(
          '${ApiConstants.subscriptionsUrl}/${widget.subscription.id}/payments');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _payments = data.map((e) => SubscriptionPayment.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addPayment() async {
    if (_amountController.text.isEmpty) return;
    try {
      await ApiService().post(
          '${ApiConstants.subscriptionsUrl}/${widget.subscription.id}/payments',
          {
            'amount': _amountController.text,
            'paymentDate': _paymentDate.toIso8601String().split('T')[0],
            'notes': _notesController.text,
          });
      _notesController.clear();
      _loadPayments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subscription.name} Payments')),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Record Payment'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Payment Date'),
                      subtitle:
                          Text(DateFormat('yyyy-MM-dd').format(_paymentDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _addPayment,
                      child: const Text('Record Payment'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _payments.isEmpty
                        ? const Center(child: Text('No payments yet'))
                        : ListView.builder(
                            itemCount: _payments.length,
                            itemBuilder: (context, index) {
                              final p = _payments[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.subscriptions
                                        .withValues(alpha: 0.2),
                                    child: const Icon(Icons.payment,
                                        color: AppColors.subscriptions),
                                  ),
                                  title: Text('Rp ${p.amount}'),
                                  subtitle: Text(p.paymentDate),
                                  trailing:
                                      p.notes != null && p.notes!.isNotEmpty
                                          ? const Icon(Icons.notes)
                                          : null,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
