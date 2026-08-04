import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/finance_category.dart';

class FinanceCategoryFormScreen extends StatefulWidget {
  final FinanceCategory? category;
  const FinanceCategoryFormScreen({super.key, this.category});

  @override
  State<FinanceCategoryFormScreen> createState() =>
      _FinanceCategoryFormScreenState();
}

class _FinanceCategoryFormScreenState extends State<FinanceCategoryFormScreen> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  String _type = 'expense';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    if (c != null) {
      _nameController.text = c.name;
      _iconController.text = c.icon ?? '';
      _colorController.text = c.color;
      _type = c.type;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'type': _type,
      'icon': _iconController.text,
      'color': _colorController.text,
    };
    try {
      final c = widget.category;
      if (c != null) {
        await ApiService().put('${ApiConstants.categoriesUrl}/${c.id}', body);
      } else {
        await ApiService().post(ApiConstants.categoriesUrl, body);
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
    final isEdit = widget.category != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
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
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon Name',
                hintText: 'e.g. restaurant',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color Hex',
                hintText: '#3B82F6',
              ),
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
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
