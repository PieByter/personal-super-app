import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/investment.dart';

class InvestmentFormScreen extends StatefulWidget {
  final Investment? investment;
  const InvestmentFormScreen({super.key, this.investment});

  @override
  State<InvestmentFormScreen> createState() => _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends State<InvestmentFormScreen> {
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _brokerController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'stock';
  DateTime _purchaseDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final i = widget.investment;
    if (i != null) {
      _nameController.text = i.name;
      _symbolController.text = i.symbol ?? '';
      _quantityController.text = i.quantity;
      _purchasePriceController.text = i.purchasePrice;
      _currentPriceController.text = i.currentPrice ?? '';
      _brokerController.text = i.broker ?? '';
      _notesController.text = i.notes ?? '';
      _type = i.type;
      _purchaseDate = DateTime.tryParse(i.purchaseDate) ?? DateTime.now();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _purchasePriceController.text.isEmpty) {
      return;
    }
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'type': _type,
      'symbol': _symbolController.text,
      'quantity': _quantityController.text,
      'purchasePrice': _purchasePriceController.text,
      'currentPrice': _currentPriceController.text,
      'purchaseDate': _purchaseDate.toIso8601String().split('T')[0],
      'broker': _brokerController.text,
      'notes': _notesController.text,
    };
    try {
      final i = widget.investment;
      if (i != null) {
        await ApiService().put('${ApiConstants.investmentsUrl}/${i.id}', body);
      } else {
        await ApiService().post(ApiConstants.investmentsUrl, body);
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
    final isEdit = widget.investment != null;
    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? 'Edit Investment' : 'Add Investment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'stock', child: Text('Stock')),
                DropdownMenuItem(value: 'crypto', child: Text('Crypto')),
                DropdownMenuItem(value: 'bond', child: Text('Bond')),
                DropdownMenuItem(
                    value: 'mutual_fund', child: Text('Mutual Fund')),
                DropdownMenuItem(
                    value: 'realestate', child: Text('Real Estate')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _type = v as String),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(labelText: 'Symbol/Ticker'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purchasePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Purchase Price',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Price',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Purchase Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _brokerController,
              decoration: const InputDecoration(labelText: 'Broker/Platform'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
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
    _symbolController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currentPriceController.dispose();
    _brokerController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
