import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/inventory_category.dart';

class InventoryCategoriesScreen extends StatefulWidget {
  const InventoryCategoriesScreen({super.key});

  @override
  State<InventoryCategoriesScreen> createState() =>
      _InventoryCategoriesScreenState();
}

class _InventoryCategoriesScreenState extends State<InventoryCategoriesScreen> {
  List<InventoryCategory> _categories = [];
  bool _isLoading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response =
          await ApiService().get('${ApiConstants.inventoryUrl}/categories');
      final List<dynamic> data = response is List ? response : [];
      setState(() {
        _categories = data.map((e) => InventoryCategory.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    if (_nameController.text.isEmpty) return;
    try {
      await ApiService().post('${ApiConstants.inventoryUrl}/categories', {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'icon': _iconController.text,
      });
      _nameController.clear();
      _descriptionController.clear();
      _iconController.clear();
      _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _iconController,
                  decoration: const InputDecoration(labelText: 'Icon'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _addCategory,
                  child: const Text('Add Category'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _categories.isEmpty
                        ? const Center(child: Text('No categories yet'))
                        : ListView.builder(
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final c = _categories[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.inventory.withValues(alpha: 0.2),
                                    child: const Icon(Icons.category,
                                        color: AppColors.inventory),
                                  ),
                                  title: Text(c.name),
                                  subtitle: c.description != null
                                      ? Text(c.description!)
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
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}
