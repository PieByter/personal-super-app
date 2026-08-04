import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/goal.dart';

class GoalFormScreen extends StatefulWidget {
  final SavingGoal? goal;
  const GoalFormScreen({super.key, this.goal});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _deadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _nameController.text = g.name;
      _targetController.text = g.targetAmount;
      _currentController.text = g.currentAmount;
      _deadline = g.deadline != null ? DateTime.tryParse(g.deadline!) : null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _targetController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'targetAmount': _targetController.text,
      'currentAmount': _currentController.text,
      'deadline': _deadline?.toIso8601String().split('T')[0],
    };
    try {
      final g = widget.goal;
      if (g != null) {
        await ApiService().put('${ApiConstants.goalsUrl}/${g.id}', body);
      } else {
        await ApiService().post(ApiConstants.goalsUrl, body);
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
    final isEdit = widget.goal != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Goal' : 'Add Saving Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Amount',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline'),
              subtitle: Text(_deadline != null
                  ? DateFormat('yyyy-MM-dd').format(_deadline!)
                  : 'Optional'),
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
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }
}
