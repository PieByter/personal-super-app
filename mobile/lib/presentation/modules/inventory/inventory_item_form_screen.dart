import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/inventory.dart';

class InventoryItemFormScreen extends StatefulWidget {
  final InventoryItem? item;
  const InventoryItemFormScreen({super.key, this.item});

  @override
  State<InventoryItemFormScreen> createState() =>
      _InventoryItemFormScreenState();
}

class _InventoryItemFormScreenState extends State<InventoryItemFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _locationController = TextEditingController();
  String _condition = 'good';
  DateTime? _purchaseDate;
  DateTime? _warrantyExpiry;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    if (i != null) {
      _nameController.text = i.name;
      _descriptionController.text = i.description ?? '';
      _brandController.text = i.brand ?? '';
      _modelController.text = i.model ?? '';
      _serialController.text = i.serialNumber ?? '';
      _purchasePriceController.text = i.purchasePrice ?? '';
      _currentValueController.text = i.currentValue ?? '';
      _locationController.text = i.location ?? '';
      _condition = i.condition;
      _purchaseDate =
          i.purchaseDate != null ? DateTime.tryParse(i.purchaseDate!) : null;
      _warrantyExpiry = i.warrantyExpiry != null
          ? DateTime.tryParse(i.warrantyExpiry!)
          : null;
      _isActive = i.isActive;
    }
  }

  Future<void> _pickDate({required bool isWarranty}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isWarranty
          ? (_warrantyExpiry ?? DateTime.now())
          : (_purchaseDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isWarranty) {
          _warrantyExpiry = picked;
        } else {
          _purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'brand': _brandController.text,
      'model': _modelController.text,
      'serialNumber': _serialController.text,
      'purchasePrice': _purchasePriceController.text,
      'currentValue': _currentValueController.text,
      'condition': _condition,
      'location': _locationController.text,
      'purchaseDate': _purchaseDate?.toIso8601String().split('T')[0],
      'warrantyExpiry': _warrantyExpiry?.toIso8601String().split('T')[0],
      'isActive': _isActive,
    };
    try {
      final i = widget.item;
      if (i != null) {
        await ApiService().put('${ApiConstants.inventoryUrl}/${i.id}', body);
      } else {
        await ApiService().post(ApiConstants.inventoryUrl, body);
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
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Item' : 'Add Inventory Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
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
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(labelText: 'Model'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serialController,
              decoration: const InputDecoration(labelText: 'Serial Number'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: const [
                DropdownMenuItem(value: 'excellent', child: Text('Excellent')),
                DropdownMenuItem(value: 'good', child: Text('Good')),
                DropdownMenuItem(value: 'fair', child: Text('Fair')),
                DropdownMenuItem(value: 'poor', child: Text('Poor')),
                DropdownMenuItem(value: 'broken', child: Text('Broken')),
              ],
              onChanged: (v) => setState(() => _condition = v as String),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _purchasePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price',
                      prefixText: 'Rp ',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _currentValueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current Value',
                      prefixText: 'Rp ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Purchase Date'),
              subtitle: Text(_purchaseDate != null
                  ? DateFormat('yyyy-MM-dd').format(_purchaseDate!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isWarranty: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Warranty Expiry'),
              subtitle: Text(_warrantyExpiry != null
                  ? DateFormat('yyyy-MM-dd').format(_warrantyExpiry!)
                  : 'Optional'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isWarranty: true),
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
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
