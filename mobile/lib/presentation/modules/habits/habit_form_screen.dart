import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/habit.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;
  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();
  final _reminderController = TextEditingController();
  String _frequency = 'daily';
  List<int> _targetDays = [1, 2, 3, 4, 5, 6, 7];
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    if (h != null) {
      _nameController.text = h.name;
      _descriptionController.text = h.description ?? '';
      _iconController.text = h.icon ?? '';
      _colorController.text = h.color;
      _targetController.text = h.targetValue ?? '';
      _unitController.text = h.unit ?? '';
      _reminderController.text = h.reminderTime ?? '';
      _frequency = h.frequency;
      _targetDays = h.targetDays ?? [1, 2, 3, 4, 5, 6, 7];
      _isActive = h.isActive;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final body = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'icon': _iconController.text,
      'color': _colorController.text,
      'targetValue': _targetController.text,
      'unit': _unitController.text,
      'frequency': _frequency,
      'targetDays': _targetDays,
      'reminderTime': _reminderController.text,
      'isActive': _isActive,
    };
    try {
      final h = widget.habit;
      if (h != null) {
        await ApiService().put('${ApiConstants.habitsUrl}/${h.id}', body);
      } else {
        await ApiService().post(ApiConstants.habitsUrl, body);
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
    final isEdit = widget.habit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Habit' : 'Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Habit Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (v) => setState(() => _frequency = v as String),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reminderController,
              decoration: const InputDecoration(
                labelText: 'Reminder Time',
                hintText: 'HH:MM',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _iconController,
              decoration: const InputDecoration(labelText: 'Icon Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color Hex'),
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
    _iconController.dispose();
    _colorController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _reminderController.dispose();
    super.dispose();
  }
}
